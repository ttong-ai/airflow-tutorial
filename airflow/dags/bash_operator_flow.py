from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

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

# Initialize the DAG
dag = DAG(dag_id="write_read_file_bash", default_args=default_args, schedule_interval="@once")

# Bash commands that will be executed in the tasks
write_file_command = "python $AIRFLOW_HOME/app/write_numbers_file.py"
read_file_command = (
    "python $AIRFLOW_HOME/app/read_numbers_file.py --file_name=$AIRFLOW_HOME/{{ var.value.output_file }}"
)

# t1, t2 are tasks tasks created by instantiating operators
t1 = BashOperator(task_id="write_numbers_file", bash_command=write_file_command, dag=dag)
t2 = BashOperator(task_id="read_numbers_file", bash_command=read_file_command, dag=dag)

# Set task order
t2.set_upstream(t1)
