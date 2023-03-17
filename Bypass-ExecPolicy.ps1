function Bypass-ExecPolicy ([string]$File) {

    ### ONE-LINER SYNTAX ###
    # iex ([string](Get-Content <file> | % { "$_`n" }))

    return ([string](Get-Content $File | % { "$_`n" }))
}