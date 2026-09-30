# Output data format:
#   {
#     "filegen": [<output-file-names>]
#   }
def filegen(name, stage, filenames):
    def filegen_task(dep_infos):
        return {
            # generic-task-specific vars
            "root": {},
            "env": {},
            "cmds": [ "echo '{}' > '{}'".format(f.split('.')[0], f)
                      for f in filenames] + ["sleep 5"],
            # task outputs
            "outputs": filenames,
            "data": {"filegen": filenames}
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=filegen_task,
    )

# Generates capitalized versions from outputs of any 'filegen' job
def toupper(name, stage, deps):
    def toupper_task(dep_infos):
        root = {}
        outfiles = {}
        for info in dep_infos:
            print(info)
            data = info["data"]
            artifacts = info["artifacts"]
            if "filegen" in data:
                # this is comming from an filegen job
                # -> stage its outputs and capitalize them
                for filename in data["filegen"]:
                    infile = "in/" + filename
                    outfile = filename
                    root[infile] = artifacts[filename]
                    if outfile in outfiles.keys():
                        fail("toupper failed with conflict on {}".format(outfile))
                    outfiles[outfile] = infile
        return {
            "root": root,
            "env": {},
            "cmds": [ "cat {} | tr 'a-z' 'A-Z' > {}".format(inf, outf)
                      for outf, inf in outfiles.items()] + ["sleep 5"],
            "data": {},
            "outputs": [f for f in outfiles.keys()],
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=toupper_task,
        deps=deps,
    )
