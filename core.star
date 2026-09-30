def generic_job(jobname, stage, cmds, outs, deps=[]):
    def generic_task(dep_infos):
        root = {}
        for info in dep_infos:
            data = info["data"]
            artifacts = info["artifacts"]
            for path, files in data.items():
                for file in files:
                    root[path + '/' + file] = artifacts[file]
        return {
            # common job description fields
            "inputs": root,
            "outputs": outs,
            "data": {jobname: outs},
            # generic-job-specific description fields
            "env": {},
            "cmds": cmds,
        }
    return job(
        name=jobname,
        stage=stage,
        type="generic",
        call=generic_task,
        deps=deps,
    )