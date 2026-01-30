@echo off
:: Chrome could be installed in 2 different locations.
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
	"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --app="file://%~dp0html/index.html"
) else if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
	"C:\Program Files\Google\Chrome\Application\chrome.exe" --app="file://%~dp0html/index.html"
) else if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
	"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app="file://%~dp0html/index.html"
) else if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
	"C:\Program Files\Microsoft\Edge\Application\msedge.exe" --app="file://%~dp0html/index.html"
) else (
	echo Neither Chrome nor Edge browser found in standard locations.
	pause
)