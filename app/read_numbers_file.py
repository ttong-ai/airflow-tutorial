def main(file_name="", *args, **kwargs):
    print(args)
    print(kwargs)
    with open(file_name, "r") as f:
        for line in f:
            print("Reading num: " + line.strip("\n"))
        print("File read complete!")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--file_name", default="file.txt")
    args = parser.parse_args()
    args = vars(args)

    main(**args)
