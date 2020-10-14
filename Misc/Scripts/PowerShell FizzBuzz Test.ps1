<#
PowerShell FizzBuzz Test

.ASSIGNMENT
    Write a program that prints the numbers from 1 to 100.
    But for multiples of three print “Fizz” instead of the number and for the multiples of five print “Buzz”.
    For numbers which are multiples of both three and five print “FizzBuzz”.

.SOLUTION
    Author: David C. Bird
    Date: October 14, 2020
#>

# Create an array of values from 1 to 100
$Values = @(1..100)

# Enumerate through the values
foreach ($Value in $Values) {

    # If the value is a multiple of 3 and 5, print FizzBuzz
    if ($Value % 3 -eq 0 -and $Value % 5 -eq 0) {
        Write-Host "FizzBuzz" -ForegroundColor Green
    }

    # If the value is a multiple of 3, print Fizz
    if ($Value % 3 -eq 0) {
        Write-Host "Fizz" -ForegroundColor Green
    }

    # If the value is a multiple of 5, print Buzz
    if ($Value % 5 -eq 0) {
        Write-Host "Buzz" -ForegroundColor Green
    }

    # Else print the value
    else {
        Write-Host "$($Value)" -ForegroundColor Green
    }

}