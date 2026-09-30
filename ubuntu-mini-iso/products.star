# load core template function for defining an image product
load("core/core.star", "image_product", "test_static_validation_job", "test_release_job")

def products(series):
    return [
        image_product(project="ubuntu-mini-iso", subproject="live", arch="amd64"),
    ]


def test_jobs(series, channel, build_job):
    if channel == "release":
        return [test_release_job(name="test_release", stage="test", deps=[build_job])]
    return []


defs = dict(
    products = products,
    test_jobs = test_jobs,
)