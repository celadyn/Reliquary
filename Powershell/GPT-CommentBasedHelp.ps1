#### prompts for comment-based help! ###

## first: start with a function. it'll have to be an actual FUNCTION not a binary cmdlet. don't get cheeky!
$Definition = Get-Item function:Get-MgGraphAllPages | Select-Object -ExpandProperty Definition

## version 1 - basics!
$CommentBasedHelpPrompt = "Generate a comment-based help block for this powershell function."

$Definition | ai -inputPrompt $CommentBasedHelpPrompt | Set-Clipboard



## version 2 - avoid pointless explanation and attempts to modify the function
$CommentBasedHelpPrompt= "Generate a comment-based help block for this powershell function. Start with <# and end with #>. Do not modify the function or explain anything outside of the comment-based help block."

$Definition | ai -inputPrompt $CommentBasedHelpPrompt | Set-Clipboard



## version 3 - includes .NOTES, enforce indentation, 
$CommentBasedHelpPrompt = "Generate a comment-based help block for this powershell function. Start with <# and end with #>. Do not modify the function or explain anything outside of the comment-based help block. The comment block should be indented one tab from the left. Add a custom section named 'NOTES' which contains empty fields for Author, Module Name, and Version History. Include 2 examples."

$Definition | ai -inputPrompt $CommentBasedHelpPrompt -max_tokens 500 | Set-Clipboard



## version 4 - add specific guidance for examples
$CommentBasedHelpPrompt = "Generate a comment-based help block for this powershell function. Start with <# and end with #>. Do not modify the function or explain anything outside of the comment-based help block. The comment block should be indented one tab from the left. Add a custom section named 'NOTES' which contains empty fields for Author, Module Name, and Version History. Include 2 examples showing varied use cases including piped input or csv-exported output, and only use functions available in Powershell 5.1 or in the function's module file."

$Definition | ai -inputPrompt $CommentBasedHelpPrompt -max_tokens 500 | Set-Clipboard

