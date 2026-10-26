
$startMarker = '<!-- BEGIN MENU -->'
$endMarker = '<!-- END MENU -->'

$newMenu = @"
$startMarker
<button class='menu-toggle' onclick='toggleMenu()'>&#9776; Menu</button>
<div class='sidebar' id='menu'>
    <h2>Menu Lezioni</h2>
    <ul>
        <li><a href='lez1/lez1_1.html'>Lezione 1: Modello relazionale</a></li>
        <li><a href='lez2/lez2_1.html'>Lezione 2: Modello E-R</a></li>
        <li><a href='lez3/lez3_1.html'>Lezione 3: Algebra relazionale</a></li>
        <li><a href='lez4/lez4_1.html'>Lezione 4: PHP + MySQL + HTML/CSS</a></li>
        <li><a href='lez5/lez5_1.html'>Lezione 5: Normalizzazione</a></li>
        <li><a href='lez6/lez6_1.html'>Lezione 6: Transazioni concorrenti</a></li>
        <li><a href='esercitazioni/dbms_minimale/consegna.html'>Laboratorio: MiniDB su file binario</a></li>
    </ul>
</div>
$endMarker
"@

Get-ChildItem -Filter *.html | ForEach-Object {
    $path = $_.FullName
    $content = Get-Content $path -Raw -Encoding utf8

    # Rimuove TUTTI i blocchi vecchi <!-- BEGIN MENU --> ... <!-- END MENU -->
    while ([regex]::IsMatch($content, "$startMarker.*?$endMarker", 'Singleline')) {
        $content = [regex]::Replace($content, "$startMarker.*?$endMarker", "", 'Singleline')
    }

    Write-Host "Scrivo menu aggiornato in: $($_.Name)"
    $content = $content -replace '<body>', "<body>`n$newMenu"

    $toggleJs = @"
<script>
function toggleMenu() {
    const menu = document.getElementById('menu');
    menu.classList.toggle('open');
}
</script>
"@

    if ($content -notmatch 'function toggleMenu') {
        $content = $content -replace '</body>', "$toggleJs`n</body>"
    }

    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBomEncoding)
}

Write-Host "Modifica completata."
