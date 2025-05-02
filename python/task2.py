import json
import requests
import sys

ACCESS_TOKEN = 'Tt.2Iv46AZKynGS5hz60l.3Qe4xX3pSgZF3om6JxYZQCaUIT356WqCKbQMT5T8tpHUBptNckN1qfuELgzuHVtyv9nzZfG6woelD5KZRaGa-b3Yq6q7prTeoEJsQtcLoV'

BASE_URL = "https://api.surveymonkey.com/v3"
HEADERS = {
    "Authorization": f"Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json",
    "Accept": "application/json"
}

def create_survey(title):
    url = f"{BASE_URL}/surveys"
    payload = {"title": title}
    response = requests.post(url, headers=HEADERS, json=payload)

    if response.status_code == 201:
        survey_id = response.json().get('id')
        print(f"Survey created with ID: {survey_id}")
        return survey_id
    else:
        print(f"Error creating survey: {response.status_code} - {response.text}")
        return None

def create_page(survey_id, page_title):
    url = f"{BASE_URL}/surveys/{survey_id}/pages"
    payload = {"title": page_title}
    response = requests.post(url, headers=HEADERS, json=payload)

    if response.status_code == 201:
        return response.json().get('id')
    else:
        print(f"Error creating page: {response.status_code} - {response.text}")
        return None

def add_questions(survey_id, page_id, questions_dict):
    for question_title, details in questions_dict.items():
        payload = {
            "headings": [{"heading": question_title}],
            "position": 0,
            "family": "single_choice",
            "subtype": "vertical",
            "answers": {
                "choices": [{"text": answer} for answer in details["Answers"]]
            }
        }

        url = f"{BASE_URL}/surveys/{survey_id}/pages/{page_id}/questions"
        response = requests.post(url, headers=HEADERS, json=payload)

        if response.status_code == 201:
            print(f" Added question: {question_title}")
        else:
            print(f"Error adding question '{question_title}': {response.status_code} - {response.text}")

def read_recipients(filepath):
    with open(filepath, 'r') as f:
        recipients = [line.strip() for line in f if line.strip()]
    return recipients

def main():
    if len(sys.argv) != 3:
        print("Usage: python create_survey.py <questions.json> <recipients.txt>")
        sys.exit(1)

    questions_file = sys.argv[1]
    recipients_file = sys.argv[2]

    with open(questions_file, 'r') as f:
        data = json.load(f)

    survey_title = list(data.keys())[0]
    page_title = list(data[survey_title].keys())[0]
    questions = data[survey_title][page_title]

    survey_id = create_survey(survey_title)
    if not survey_id:
        return

    page_id = create_page(survey_id, page_title)
    if not page_id:
        return

    add_questions(survey_id, page_id, questions)

    recipients = read_recipients(recipients_file)
    print(f"Recipients loaded: {recipients}")

if __name__ == "__main__":
    main()
