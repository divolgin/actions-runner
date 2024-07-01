const core = require('@actions/core');
const github = require('@actions/github');

async function get_workflow_runs() {
  const token = core.getInput("gh_token", { required: true });
  const ref = core.getInput("ref", { required: true });
  const run_id = core.getInput("run_id", { required: true });

  const octokit = github.getOctokit(token);

  const {
    data: {
      workflow_runs,
    },
  } = await octokit.rest.actions.listWorkflowRunsForRepo({
    ...github.context.repo,
  });

  let this_run = null;
  for (const i in workflow_runs) {
    const workflow_run = workflow_runs[i];
    if (workflow_run.id.toString() === run_id) {
      this_run = workflow_run;
      break;
    }
  }

  if (!this_run) {
    throw new Error(`Could not find workflow ${run_id} run`);
  }

  const earlier_runs = []; // runs that were triggered earlier and still have not completed
  const later_runs = []; // runs that were triggered after this one and have not completed

  console.log("Looking for earlier and later runs");
  for (const i in workflow_runs) {
    const workflow_run = workflow_runs[i];

    // We only want THIS workflow. If name ever changes, this comparison will not work. So don't change the name.
    if (this_run.name !== workflow_run.name) {
      continue;
    }

    if (workflow_run.status === "completed") {
      continue;
    }

    console.log("found workflow_run", workflow_run);

    if (workflow_run.created_at < this_run.created_at) {
      console.log(`Found earlier run ${workflow_run.html_url}`);
      earlier_runs.push(workflow_run);
      continue;
    }

    if (workflow_run.created_at > this_run.created_at){
      console.log(`Found later run ${workflow_run.html_url}`);
      later_runs.push(workflow_run);
      continue;
    }
  }

  return {earlier_runs, later_runs};
}

// If there are workflow runs that started earlier, wait for them finish before proceeding.
// If there are workflows that started later, stop this workflow. Let new one run.
async function run() {
  try { // While this try/catch is not necessary, it seems to help Github Actions flush workflow logs.
    while (true) {
      const {earlier_runs, later_runs} = await get_workflow_runs();
      if (earlier_runs.length > 0) {
        console.log(`Found ${earlier_runs.length} earlier runs. Waiting for them to finish.`)
        await new Promise(r => setTimeout(r, 5000));
        continue;
      }

      if (later_runs.length > 0) {
        console.log(`Found ${later_runs.length} later runs that have already started. Stopping this workflow.`)
        core.setOutput("next-step", "stop");
        return;
      }

      core.setOutput("next-step", "go");
      return;
    }
  } catch (error) {
    throw error;
  }
}

run();
