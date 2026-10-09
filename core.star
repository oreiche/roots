# Metadata output: {
#   "greeter_results": [<output-file-names>]
# }
def greeter(name, stage, greets):
    def greeter_task(dep_infos):
        outputs = [g+'.txt' for g in greets]
        return {
            "inputs": {},
            "env": {},
            "cmds": ["echo 'Hello {0}!' > '{0}.txt'".format(g)
                     for g in greets],
            "outputs": outputs,
            "data": {"greeter_results": outputs}
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=greeter_task,
    )

# Generates capitalized versions from outputs of any 'greeter' job
def toupper(name, stage, deps):
    def toupper_task(dep_infos):
        inputs, cmds, outputs = {}, [], []
        for dep in dep_infos:
            data, artifacts = dep["data"], dep["artifacts"]
            # only process deps that produced 'greeter'
            for filename in data.get("greeter_results", []):
                # stage input artifacts to subfolder 'in'
                infile = "in/"+filename
                if infile in inputs:
                    # fails at evaluation already, before runtime
                    fail("name conflict on input file " + filename)
                inputs[infile] = artifacts[filename]
                # generate the to-upper shell command
                cmds += ["tr 'a-z' 'A-Z' < {} > {}".format(infile, filename)]
                # record the output filename
                outputs += [filename]
        return {
            "inputs": inputs,
            "env": {},
            "cmds": cmds,
            "data": {},
            "outputs": outputs,
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=toupper_task,
        deps=deps,
    )
