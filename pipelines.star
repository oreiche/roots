load("core.star", "filegen", "toupper")

def register_pipelines():
    return [
        pipeline(
            groups=["test"],
            name="pipeline",
            stages=["generate", "modify"],
            jobs=[
                filegen(
                    name="foo",
                    stage="generate",
                    filenames=["foo.txt"],
                ),
                filegen(
                    name="bar_and_baz",
                    stage="generate",
                    filenames=["bar.txt", "baz.txt"],
                ),
                # Try adding more 'filegen' jobs (with different filenames).
                # filegen(
                #     name="qux",
                #     stage="generate",
                #     filenames=["qux.txt"],
                # ),
                #
                # The 'toupper' template will automatically handle the new file
                # after you added the new job as a dependency.
                toupper(
                    name="upper",
                    stage="modify",
                    deps=["foo", "bar_and_baz"]
                ),
            ]
        )
    ]
