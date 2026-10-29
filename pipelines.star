load("core.star", "generic_job")

def register_pipelines():
    p = pipeline(
        groups=["test"],
        name="helloworld",
        stages=["generate", "modify"],
        jobs=[
            generic_job(
                jobname="hello",
                stage="generate",
                cmds=["echo 'Hello World' > hello.txt"],
                outs=["hello.txt"],
            ),
            generic_job(
                jobname="upper",
                stage="modify",
                cmds=["cat hello/hello.txt | tr 'a-z' 'A-Z' > HELLO.txt"],
                outs=["HELLO.txt"],
                deps=["hello"]
            ),
        ] + ([
            generic_job(
                jobname="lower",
                stage="modify",
                cmds=["cat hello/hello.txt | tr 'A-Z' 'a-z' > hello.txt"],
                outs=["hello.txt"],
                deps=["hello"]
            ),
        ] if getenv("channel", default="edge") == "stable" else [])
    )
    return [p]
