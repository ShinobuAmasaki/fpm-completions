$fpmCompletions = {
	param($wordToComplete, $commandAst, $cursorPosition);

	# Subcommands
	$subcommands = ("build", "clean", "help", "install", "new", "publish", "run", "test")


	# Long Options
	$options = @("--version", "--help", "--verbose", "--runner", "--compiler")
	
	# runnnerの候補
	$runnerCommands = @("cafrun", "mpiexec", "mpirun", "gdb", "varglind")

	# コンパイラ候補
	$compilerCommands = @("gfortran", "ifort", "ifx", "flang")
	

	# $tokens = $commandAst.Extent.Text -split '\s+'

	$tokens = $commandAst.CommandElements | ForEach-Object { $_.Value }

	$filteredOptions = $options | Where-Object { $_ -notin $tokens }

	if ($cursorPosition -gt $commandAst.Extent.Text.Length) {
		$lastToken = $tokens[-1]
	} elseif ($tokens.Count -ge 2) {
		$lastToken = $tokens[-2]
	} else { "" }

	# Write-Host "L25: " $filteredOptions
	# Write-Host "L26: " $lastToken

	if ($lastToken -eq 'fpm') {
		$filteredItems = ($subcommands) | Where-Object { $_ -like "$wordToComplete*" }
	} elseif ($lastToken -eq '--runner') {
		$filteredItems = $runnerCommands | Where-Object { $_ -like "$wordToComplete*" }
	} elseif ($lastToken -eq '--compiler') {
		$filteredItems = $compilerCommands | Where-Object { $_ -like "$wordToComplete*"}
	} else {
		$filteredItems = ($filteredOptions) | Where-Object { $_ -like "$wordToComplete*" }
	}


	# $filteredItems = $subcommands | Where-Object { $_ -like "$wordToComplete*" }

	foreach ($item in $filteredItems)
	{
		$completionText = $item;

		$listItemText = $item;

		$toolTip = "'$item' subcommand of fpm (Fortran Package Manager) command";

		# $resultType = [System.Management.Automation.CompletionResultType]::ProviderItem;
		$resultType = [System.Management.Automation.CompletionResultType]::ParameterValue;

		[System.Management.Automation.CompletionResult]::new($completionText, $listItemText, $resultType, $toolTip);
	}

}

Register-ArgumentCompleter -CommandName fpm -ScriptBlock $fpmCompletions;