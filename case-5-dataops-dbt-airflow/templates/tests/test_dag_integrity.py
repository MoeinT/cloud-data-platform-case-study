"""DAG integrity tests: run in CI on every pull request. No Airflow server needed."""
import pytest
from airflow.models import DagBag

dag_bag = DagBag(dag_folder="dags/", include_examples=False)


def test_no_import_errors():
    # Syntax errors, missing imports, cycles, duplicate dag_ids
    assert dag_bag.import_errors == {}, dag_bag.import_errors


@pytest.mark.parametrize("dag_id", dag_bag.dag_ids)
def test_team_rules(dag_id):
    dag = dag_bag.get_dag(dag_id)
    assert dag.owner != "airflow", "set a real owner"
    assert dag.tags, "add tags"
    assert dag.default_args.get("retries", 0) >= 1, "set retries"
    assert dag.catchup is False, "turn catchup off"
    assert dag.on_failure_callback, "add a failure alert"
