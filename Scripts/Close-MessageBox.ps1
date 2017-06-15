FUNCTION Close-MessageBox
{

    TRY
    {
        $Runspace = Get-Runspace -Name "MessageBox"
        $null = $Runspace.Dispose()
        $null = $Script:MessageBox.form1.Close()
    }

    CATCH
    {
        $_    
    }

}
