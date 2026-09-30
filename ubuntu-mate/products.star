# load core template function for defining an image product
load("core/core.star", "image_product", "test_static_validation_job", "test_release_job")

def products(series):
    if series == "stonking":
        return [
            image_product(project="ubuntu-mate", subproject="live", arch="amd64")
        ]
    return []


def test_jobs(series, channel, build_job):
    jobs = [
        test_static_validation_job(name="static_validation", stage="test", deps=[build_job]),
    ]

    if channel == "release":
        jobs += [test_release_job(name="test_release", stage="test", deps=[build_job])]

    return jobs


defs = dict(
    products = products,
    test_jobs = test_jobs,
)