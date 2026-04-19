*** Settings ***
Library    Browser
Suite Setup    Setup
Suite Teardown    Teardown

*** Variables ***
${URL}    https://www.aktia.fi/
${HEADLESS}    false
${COOKIE_BUTTON}    role=button[name="Hyväksy kaikki evästeet"]
${OPEN_CHAT_BUTTON}    role=button[name="Avaa chat palvelu"]
${CHAT_INPUT}    role=textbox[name="Kirjoita kysymyksesi tähän"]
${CUSTOMER_SERVICE_BUTTON}    role=button[name="Asiakaspalvelun"]
${EXPECTED_TEXT}    Jos soitat ulkomailta

*** Test Cases ***
Aktiabot chat responds to user queries
    Click    ${OPEN_CHAT_BUTTON}
    Fill Text    ${CHAT_INPUT}    What time the bank opens?
    Press Keys    ${CHAT_INPUT}    Enter
    Click    ${CUSTOMER_SERVICE_BUTTON}
    Get Text    text=${EXPECTED_TEXT}
    Close Browser

*** Keywords ***
Setup
    New Browser    chromium    headless=${HEADLESS}    args=["--start-maximized"]
    New Context    viewport=${None}
    Set Browser Timeout    30s
    New Page    ${URL}
    Click    ${COOKIE_BUTTON}

Teardown
    Close Browser