import os
from airflow.models import Variable

home_dir = os.environ["AIRFLOW_HOME"]


def main():
    with open(os.path.join(home_dir, Variable.get("output_file")), "w+") as f:
        for x in range(1, 1000):
            f.write(str(x) + "\n")
            print("Writing no: " + str(x))
        print("Write file complete!")
        return 0


if __name__ == "__main__":
    main()
