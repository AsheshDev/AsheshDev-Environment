# AsheshDevelopment
# Filename: Install-FedoraWSL-GUI.ps1

<#
.SYNOPSIS
    PowerShell script to install Fedora on WSL with Desktop GUI 
    and set up a development environment with a full-fledged GUI interface.
.DESCRIPTION
    This script provides a graphical user interface (GUI) using WPF for entering Git 
    credentials, installing Fedora on WSL, and configuring the environment 
    for development with a GNOME Desktop GUI.
#>

# =============================================
# COLOR CODES (Dracula Neon Vibrant Color Scheme)
# =============================================
$Colors = @{
    "Info"    = "Cyan"
    "Success" = "Green"
    "Warning" = "Yellow"
    "Error"   = "Red"
    "Reset"   = "White"
}

# =============================================
# Function: Show-Message
# Description: Displays a color-coded message
# =============================================
function Show-Message {
    param (
        [string]$Message,
        [string]$Type = "Info"
    )
    $Color = $Colors[$Type]
    Write-Host $Message -ForegroundColor $Color
}

# =============================================
# Function: Create-GUI
# Description: Creates a WPF GUI for entering Git credentials
# =============================================
function Create-GUI {
    Add-Type -AssemblyName PresentationFramework

    $XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Fedora WSL Installation" Height="250" Width="400">
    <Grid>
        <Label Content="Git User Name:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,10,0,0"/>
        <TextBox Name="GitUserName" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="120,10,0,0" Width="250"/>
        
        <Label Content="Git User Email:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,50,0,0"/>
        <TextBox Name="GitUserEmail" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="120,50,0,0" Width="250"/>
        
        <Button Name="InstallButton" Content="Install" Width="100" Height="30" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,20" />
    </Grid>
</Window>
"@

    $Reader = New-Object System.Xml.XmlNodeReader $XAML
    $Window = [System.Windows.Markup.XamlReader]::Load($Reader)
    
    $Window.FindName("InstallButton").Add_Click({
        $Global:GitUserName = $Window.FindName("GitUserName").Text
        $Global:GitUserEmail = $Window.FindName("GitUserEmail").Text
        $Window.Close()
    })
    
    $Window.ShowDialog() | Out-Null
}

# =============================================
# Function: Install-FedoraWSL
# Description: Installs Fedora on WSL
# =============================================
function Install-FedoraWSL {
    Show-Message "Installing Fedora on WSL..." "Info"
    wsl --install -d Fedora
    if ($LASTEXITCODE -eq 0) {
        Show-Message "Fedora installed on WSL successfully." "Success"
    } else {
        Show-Message "Failed to install Fedora on WSL." "Error"
        exit 1
    }
}

# =============================================
# Function: Update-System
# Description: Updates and upgrades the Fedora system
# =============================================
function Update-System {
    Show-Message "Updating and upgrading the Fedora system..." "Info"
    wsl -d Fedora -- sudo dnf update -y && sudo dnf upgrade -y
    if ($LASTEXITCODE -eq 0) {
        Show-Message "System updated and upgraded successfully." "Success"
    } else {
        Show-Message "Failed to update and upgrade the system." "Error"
        exit 1
    }
}

# =============================================
# Function: Install-DevTools
# Description: Installs development tools and essentials
# =============================================
function Install-DevTools {
    Show-Message "Installing development tools and essentials..." "Info"
    wsl -d Fedora -- sudo dnf groupinstall "Development Tools" -y
    wsl -d Fedora -- sudo dnf install git vim curl wget -y
    if ($LASTEXITCODE -eq 0) {
        Show-Message "Development tools installed successfully." "Success"
    } else {
        Show-Message "Failed to install development tools." "Error"
        exit 1
    }
}

# =============================================
# Function: Setup-Git
# Description: Configures Git with user credentials
# =============================================
function Setup-Git {
    Show-Message "Configuring Git with user credentials..." "Info"
    wsl -d Fedora -- git config --global user.name "$Global:GitUserName"
    wsl -d Fedora -- git config --global user.email "$Global:GitUserEmail"
    if ($LASTEXITCODE -eq 0) {
        Show-Message "Git configured successfully." "Success"
    } else {
        Show-Message "Failed to configure Git." "Error"
        exit 1
    }
}

# =============================================
# Function: Install-ExtraPackages
# Description: Installs additional development packages
# =============================================
function Install-ExtraPackages {
    Show-Message "Installing additional development packages..." "Info"
    wsl -d Fedora -- sudo dnf install gcc gcc-c++ make python3 python3-pip nodejs npm SDL2-devel mesa-libGL-devel -y
    if ($LASTEXITCODE -eq 0) {
        Show-Message "Additional development packages installed successfully." "Success"
    } else {
        Show-Message "Failed to install additional development packages." "Error"
        exit 1
    }
}

# =============================================
# Function: Install-GNOME
# Description: Installs GNOME Desktop Environment
# =============================================
function Install-GNOME {
    Show-Message "Installing GNOME Desktop Environment..." "Info"
    wsl -d Fedora -- sudo dnf groupinstall "GNOME Desktop Environment" -y
    if ($LASTEXITCODE -eq 0) {
        Show-Message "GNOME Desktop Environment installed successfully." "Success"
    } else {
        Show-Message "Failed to install GNOME Desktop Environment." "Error"
        exit 1
    }
}

# =============================================
# Function: Configure-GUI
# Description: Configures GUI settings for WSL
# =============================================
function Configure-GUI {
    Show-Message "Configuring GUI settings for WSL..." "Info"
    wsl -d Fedora -- echo "export DISPLAY=:0" >> ~/.bashrc
    wsl -d Fedora -- source ~/.bashrc
    Show-Message "GUI settings configured successfully." "Success"
    Show-Message "Ensure that you start an X server (e.g., VcXsrv) on Windows before launching the GUI." "Warning"
}

# =============================================
# Main Script Execution
# =============================================

# Show the GUI and get the credentials
Create-GUI

# Install Fedora WSL and configure the environment
Install-FedoraWSL
Update-System
Install-DevTools
Setup-Git
Install-ExtraPackages
Install-GNOME
Configure-GUI

Show-Message "Fedora WSL installation with GNOME Desktop GUI and development setup complete!" "Success"
