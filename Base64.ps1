function Base64 {
#.SYNOPSIS
# Converts messages to and from Base64.
# ARBITRARY VERSION NUMBER:  1.2.0
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# This function aims to expedite the process of Base64 encoding and decoding in PowerShell.  For the life of me,
# I could never remember the proper syntax to do it -- always Googling / copy and pasting.  This fixes that.
# The -Encode, -Message, and -Unicode parameters don't need to be specified; set as the default.
#
# Parameters:
#    -Encode        -->    Encodes the message
#    -Decode        -->    (Optional) Decodes the message
#    -Message       -->    The message to be encoded or decoded
#    -Unicode       -->    Uses Unicode as encoded character set
#    -ASCII         -->    (Optional) Uses ASCII as encoded character set
#    -UTF8          -->    (Optional) Uses UTF8 as encoded character set
#    -Help          -->    (Optional) Return Get-Help information
#
#
# Example Usage:
#    []  PS C:\Users\Bobby> Base64 -Message 'Test me'
#        VABlAHMAdAAgAG0AZQA=
#
#    []  PS C:\Users\Bobby> Base64 -Message 'Test me' -ASCII
#        VGVzdCBtZQ==
#
#    []  PS C:\Users\Bobby> Base64 -Encode -Message 'Final test.' -ASCII | % { Base64 -Decode $_ }
#        楆慮⁬整瑳�
#    
#    []  PS C:\Users\Bobby> Base64 -Encode -Message 'Final test.' -ASCII | % { Base64 -Decode $_ -ASCII }
#        Last test
#
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools


    Param (
        [switch] $Encode = $TRUE,
        [switch] $Decode,
        [string] $Message,
        [switch] $Unicode,
        [switch] $ASCII,
        [switch] $UTF8,
        [switch] $Help
    )


    # Return help information
    if ($Help) { return Get-Help Base64 }


    # Error Correction
    if (!$Message) { return (Write-Host 'Input message to encode/decode.' -ForegroundColor Red) }


    # Probably not the most efficient way of doing this.
    if ($Decode) { $Encode = $FALSE }


    # Establish encoded character set
    if ($ASCII) { $CodeType = 'ASCII' }
    elseif ($UTF8) { $CodeType = 'UTF8' }
    else { $CodeType = 'Unicode' }


    # Convert message to / from Base64
    if ($Encode) { $Output = [convert]::ToBase64String([System.Text.encoding]::$CodeType.GetBytes($Message)) }
    elseif ($Decode) { $Output = [System.Text.Encoding]::$CodeType.GetString([System.Convert]::FromBase64String($Message)) }


    return $Output 
}