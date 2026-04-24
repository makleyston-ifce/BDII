import pandas as pd
import os
import argparse


def normalize_df(df):
    # Normalize NULLs
    df = df.fillna("NULL")

    # Convert everything to string
    df = df.astype(str)

    # Sort columns alphabetically
    df = df.reindex(sorted(df.columns), axis=1)

    # Sort rows
    df = df.sort_values(by=list(df.columns)).reset_index(drop=True)

    return df


def compare_dataframes(df_expected, df_student):
    if df_expected.shape != df_student.shape:
        return False, "Different shape"

    comparison = df_expected.eq(df_student)

    if comparison.all().all():
        return True, None
    else:
        return False, "Different content"


def compare_csv_files(expected_file, student_file):
    try:
        df_expected = pd.read_csv(expected_file)
    except Exception as e:
        return False, f"Error reading expected: {e}"

    try:
        df_student = pd.read_csv(student_file)
    except Exception as e:
        return False, f"Error reading student: {e}"

    df_expected = normalize_df(df_expected)
    df_student = normalize_df(df_student)

    return compare_dataframes(df_expected, df_student)


def main():
    parser = argparse.ArgumentParser(description="SQL CSV Checker")
    parser.add_argument("--expected", required=True, help="Path to expected CSV directory")
    parser.add_argument("--student", required=True, help="Path to student CSV directory")

    args = parser.parse_args()

    expected_dir = args.expected
    student_dir = args.student

    expected_files = sorted([f for f in os.listdir(expected_dir) if f.endswith(".csv")])

    correct = []
    wrong = []
    missing = []

    print("\nChecking files...\n")

    for file in expected_files:
        expected_path = os.path.join(expected_dir, file)
        student_path = os.path.join(student_dir, file)

        if not os.path.exists(student_path):
            print(f"[MISS] {file} (student file not found)")
            missing.append(file)
            continue

        is_correct, error = compare_csv_files(expected_path, student_path)

        if is_correct:
            print(f"[OK]   {file}")
            correct.append(file)
        else:
            print(f"[ERR]  {file} -> {error}")
            wrong.append(file)

    print("\n========== SUMMARY ==========")
    print(f"Correct : {len(correct)}")
    print(f"Wrong   : {len(wrong)}")
    print(f"Missing : {len(missing)}")

    if wrong:
        print("\nWrong files:")
        for f in wrong:
            print(f" - {f}")

    if missing:
        print("\nMissing files:")
        for f in missing:
            print(f" - {f}")


if __name__ == "__main__":
    main()