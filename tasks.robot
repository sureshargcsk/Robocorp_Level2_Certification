*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Excel.Application
Library    RPA.Tables
Library    RPA.RobotLogListener
Library    RPA.Desktop
Library    RPA.PDF
Library    RPA.Archive

*** Variables ***
${url}    https://robotsparebinindustries.com/#/
${csv_url}    https://robotsparebinindustries.com/orders.csv
${orders_filepath}    ${CURDIR}${/}orders.csv 
${screenshot_dir}    ${out_dir}${/}screenshots
${receipt_dir}    ${out_dir}${/}receipts
${out_dir}           ${CURDIR}${/}output


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get Orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the Form    ${row}
        Wait Until Keyword Succeeds     10x     2s    Preview the robot
        Wait Until Keyword Succeeds     10x     2s    Submit the order
        ${screenshot} =    Take a screenshot of the robot image    ${row}[Order number]
        ${pdf_filename}=    Store the order receipt as a PDF file    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    IMG_FILE=${screenshot}    PDF_FILE=${pdf_filename}
        Go to order another robot    
    END
    Create a ZIP file of receipt PDF files
    Log Out And Close Browser
    


*** Keywords ***
Open the robot order website
    Open Available Browser    ${url}    maximized=True
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Click Button    xpath://button[contains(text(),'Log in')]
    Wait Until Element Contains    xpath://span[contains(text(),'maria')]    maria
    Click Element    xpath://*[@id="root"]/header/div/ul/li[2]/a
Get Orders
    Download    ${csv_url}    target_file=${orders_filepath}    overwrite=TRUE
    ${orders}=    Read table from CSV    path=${orders_filepath}    header=True
    [Return]    ${orders}

Close the annoying modal
    Wait Until Page Contains Element    class:alert-buttons
    Click Button    OK

Fill the Form
    [Arguments]    ${formrow}
    #Select Head from Drop down
    Wait Until Element Is Visible   head
    Wait Until Element Is Enabled   head
    Select From List By Value    head    ${formrow}[Head]

    #Select body from radio button
    Wait Until Element Is Enabled   body
    Select Radio Button    body    ${formrow}[Body]

    #Select legs
    Wait Until Element Is Enabled    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${formrow}[Legs]

    #Select Address
    Wait Until Element Is Enabled    address
    Input Text    address    ${formrow}[Address]

Preview the robot
    Click Button    preview
    Wait Until Element Is Visible    robot-preview-image

Submit the order
    Mute Run On Failure    Page Should contain Element    
    Click Button    order
    Page Should Contain Element    receipt
    Page Should Contain Element    order-another

Take a screenshot of the robot image
    [Arguments]    ${order_number}
    Set Local Variable    ${file_path}    ${screenshot_dir}${/}robot_preview_image_${order_number}.png
    Sleep   1sec
    Capture Element Screenshot    robot-preview-image    ${file_path}    
    [Return]    ${file_path}

Store the order receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt_html} =    Get Element Attribute    receipt    outerHTML
    Set Local Variable    ${pdf_file_path}    ${receipt_dir}${/}receipt_${order_number}.pdf
    Html To Pdf    ${receipt_html}    ${pdf_file_path}
    [Return]    ${pdf_file_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]     ${IMG_FILE}     ${PDF_FILE}
    Open Pdf    ${PDF_FILE}
    @{myfiles}=       Create List     ${IMG_FILE}:align=center
    Add Files To Pdf    ${myfiles}    ${PDF_FILE}    append=True
    #Close Pdf    ${PDF_FILE}

Go to order another robot
    Click Button    order-another

Create a ZIP file of receipt PDF files
    Archive Folder With Zip    ${receipt_dir}    ${out_dir}${/}all_receipts.zip  

Log Out And Close Browser
    Close Browser  








