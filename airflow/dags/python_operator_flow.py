from datetime import datetime, timedelta
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from app.read_numbers_file import main as read_numbers_file
from app.write_numbers_file import main as write_numbers_file

# Default arguments - These get passed into every task in the DAG
default_args = {
    "owner": "airflow",
    "start_date": datetime(2018, 11, 28),
    "email": ["airflow@airflow.com"],
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 3,
    "retry_delay": timedelta(seconds=5),
    # 'queue': 'bash_queue',
    # 'pool': 'backfill',
    # 'priority_weight': 10,
    # 'end_date': datetime(2016, 1, 1),
}


dag = DAG(dag_id="write_read_file_python", default_args=default_args, schedule_interval="@once")

task_write_file = PythonOperator(
    task_id="write_numbers_file", dag=dag, python_callable=write_numbers_file, op_kwargs={}
)


task_read_file = PythonOperator(
    task_id="read_numbers_file",
    dag=dag,
    python_callable=read_numbers_file,
    op_kwargs = {"file_name": Variable.get("output_file")}
)


task_write_file >> task_read_file