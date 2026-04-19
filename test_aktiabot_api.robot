*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    https://104aktia.boost.ai
${PAGE_URL}    https://www.aktia.fi/
${EXPECTED_TEXT}    Jos soitat ulkomailta

*** Test Cases ***
Aktiabot chat responds to user queries on API level
    [Documentation]    Start a session, send a message, click action link, verify response
    # Start session
    ${filter}=    Create List    chatbot-consumer-customers
    ${start_body}=    Create Dictionary
    ...    command=START
    ...    filter_values=${filter}
    ...    language=fi-FI
    ...    trigger_action=${6920}
    ...    page_url=${PAGE_URL}
    ${start}=    POST    ${BASE_URL}/api/chat/v2    json=${start_body}    expected_status=200
    ${start_json}=    Set Variable    ${start.json()}
    ${conversation}=    Get From Dictionary    ${start_json}    conversation
    ${conversation_id}=    Get From Dictionary    ${conversation}    id
    Log    Conversation ID: ${conversation_id}

    # Send a message
    ${msg_body}=    Create Dictionary
    ...    command=POST
    ...    type=text
    ...    conversation_id=${conversation_id}
    ...    value=Mitkä ovat pankin aukioloajat?
    ${msg}=    POST    ${BASE_URL}/api/chat/v2    json=${msg_body}    expected_status=200
    ${msg_json}=    Set Variable    ${msg.json()}
    Log    ${msg_json}

    # Extract Asiakaspalvelun action link id
    ${response}=    Get From Dictionary    ${msg_json}    response
    ${elements}=    Get From Dictionary    ${response}    elements
    ${link_element}=    Get From List    ${elements}    1
    ${payload}=    Get From Dictionary    ${link_element}    payload
    ${links}=    Get From Dictionary    ${payload}    links
    ${first_link}=    Get From List    ${links}    0
    ${action_id}=    Get From Dictionary    ${first_link}    id

    # Click the Asiakaspalvelun action link
    ${click_body}=    Create Dictionary
    ...    command=POST
    ...    type=action_link
    ...    conversation_id=${conversation_id}
    ...    id=${action_id}
    ${click}=    POST    ${BASE_URL}/api/chat/v2    json=${click_body}    expected_status=200
    ${click_json}=    Set Variable    ${click.json()}
    Log    ${click_json}

    # Verify response contains expected text
    ${click_response}=    Get From Dictionary    ${click_json}    response
    ${click_elements}=    Get From Dictionary    ${click_response}    elements
    ${html_content}=    Set Variable    ${EMPTY}
    FOR    ${element}    IN    @{click_elements}
        ${type}=    Get From Dictionary    ${element}    type
        IF    '${type}' == 'html'
            ${p}=    Get From Dictionary    ${element}    payload
            ${h}=    Get From Dictionary    ${p}    html
            ${html_content}=    Set Variable    ${html_content}${h}
        END
    END
    Should Contain    ${html_content}    ${EXPECTED_TEXT}
