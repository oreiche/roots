load("core.star", "greeter", "toupper")

def register_pipelines():
    return [
        pipeline(
            groups=["test"],
            name="pipeline",
            stages=["generate", "modify"],
            jobs=[
                greeter(
                    name="foo",
                    stage="generate",
                    greets=["foo"],
                ),

                # 'greeter' can produce multiple files
                greeter(
                    name="bar_and_baz",
                    stage="generate",
                    greets=["bar", "baz"],
                ),

                # Try a third job (more input files for 'toupper').
                #greeter(
                #    name="qux",
                #    stage="generate",
                #    greets=["qux"],
                #),

                # Try a conflicting job ('toupper's inputs conflict on 'bar').
                #greeter(
                #    name="bar",
                #    stage="generate",
                #    greets=["bar"],
                #),

                # The 'toupper' template will automatically handle new input
                # files after their jobs have been added to the dependency list.
                toupper(
                    name="upper",
                    stage="modify",
                    deps=["foo", "bar_and_baz"] # + ["qux", "bar"]
                ),
            ]
        )
    ]
