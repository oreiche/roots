load("core.star", "generic_job")

def register_pipelines():
    p = pipeline(
        groups=["test"],
        name="pipeline",
        stages=["build"],
        jobs=[
            generic_job(
                jobname="hello",
                stage="build",
                cmds=["echo 'Hello World' > hello.txt"],
                outs=["hello.txt"],
            ),
            generic_job(
                jobname="upper",
                stage="build",
                cmds=["cat hello/hello.txt | tr 'a-z' 'A-Z' > HELLO.txt"],
                outs=["HELLO.txt"],
                deps=["hello"]
            ),
        ]
    )
    return [p]
