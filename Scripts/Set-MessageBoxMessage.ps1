FUNCTION Set-MessageBoxMessage ($Message) {

    IF($Script:MessageBox.IsRunning -eq $true)
    {
        $Script:MessageBox.textbox1.Text = $Message
    }    

}