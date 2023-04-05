function Get-MgGraphAllPages {
    <#
    .SYNOPSIS
        Iterates through a set of pages returned from a Graph API request.

    .DESCRIPTION
        Iterates through a set of pages returned from a Graph API request.

    .PARAMETER NextLink
        The @odata.nextLink value from the previous page.

    .PARAMETER SearchResult
        The first page of results from a Graph API request.

    .PARAMETER ToPSCustomObject
        Switch parameter to convert the results to PSCustomObjects.

    .EXAMPLE
        Get-MgGraphPage -SearchResult $searchResult -ToPSCustomObject

        Iterates through the pages returned from the Graph API request and converts the results to PSCustomObjects.
    #>
    [CmdletBinding(
        ConfirmImpact = 'Medium',
        DefaultParameterSetName = 'SearchResult'
    )]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'NextLink', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('@odata.nextLink')]
        [string]$NextLink
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'SearchResult', ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [PSObject]$SearchResult
        ,
        [Parameter(Mandatory = $false)]
        [switch]$ToPSCustomObject
    )

    begin {}

    process {
        if ($PSCmdlet.ParameterSetName -eq 'SearchResult') {
            # Set the current page to the search result provided
            $page = $SearchResult

            # Extract the NextLink
            $currentNextLink = $page.'@odata.nextLink'



            # We know this is a wrapper object if it has an "@odata.context" property
            #if (Get-Member -InputObject $page -Name '@odata.context' -Membertype Properties) {
            # MgGraph update - MgGraph returns hashtables, and almost always includes .context
            # instead, let's check for nextlinks specifically as a hashtable key
            if ($page.ContainsKey('@odata.count')) {
                # Calculate the number of pages
                $totalPages = [math]::Ceiling($SearchResult.'@odata.count' / $SearchResult.'@odata.nextLink'.Split('$top=')[1].Split('&')[0])
                Write-Verbose "Total pages expected: $totalPages"
                Write-Verbose "First page value count: $($Page.'@odata.count')"    
            }

            if ($page.ContainsKey('@odata.nextLink') -or $page.ContainsKey('value')) {
                $values = $page.value
            } else { # this will probably never fire anymore, but maybe.
                $values = $page
            }

            # Output the values
            # Default returned objects are hashtables, so this makes for easy pscustomobject conversion on demand
            if ($values) {
                if ($ToPSCustomObject) {
                    $values | ForEach-Object {[pscustomobject]$_}   
                } else {
                    $values | Write-Output
                }
            }
        }

        while (-Not ([string]::IsNullOrWhiteSpace($currentNextLink)))
        {
            # Make the call to get the next page
            try {
                $page = Invoke-MgGraphRequest -Uri $currentNextLink -Method GET
            } catch {
                throw
            }

            # Extract the NextLink
            $currentNextLink = $page.'@odata.nextLink'

            # Output the items in the page
            $values = $page.value

            if ($page.ContainsKey('@odata.count')) {
                Write-Verbose "Current page value count: $($Page.'@odata.count')"    
            }

            # Default returned objects are hashtables, so this makes for easy pscustomobject conversion on demand
            if ($ToPSCustomObject) {
                $values | ForEach-Object {[pscustomobject]$_}   
            } else {
                $values | Write-Output
            }
        }
    }

    end {}
}