printf "__________________________________________________________\n"
printf "Running script to update and organize stock tickers..... /\n"
printf "________________________________________________________/\n\n"
printf "Nasdaq first...\n"
if curl -o Nasdaq_withTests.txt "https://www.nasdaqtrader.com/dynamic/SymDir/nasdaqlisted.txt"; then
        printf "\nNasdaq list has been successfully created as text file.
        \nFiltering out test issues and bloat....\n"


        awk -F '|' 'BEGIN { OFS="|" } NR==1 {print $1, $2, $3, $5, $6, $7; next} $4=="N" {
        print $1, $2, $3, $5, $6, $7} $0 ~ /File Creation Time/ {print; next} ' Nasdaq_withTests.txt > Nasdaq.txt  

        printf "Done with Nasdaq\n\n"
else
    printf "Downloading Nasdaq list failed. Check address or source.\n"
fi

printf "Now trying \"other listed\"...\n"
if curl -o other_listed_withTests.txt "https://www.nasdaqtrader.com/dynamic/SymDir/otherlisted.txt"; then
        printf "\n\"other lsited\" list has been successfully created as text file.
        \nFiltering out test issues and bloat....\n"

        awk -F '|' 'BEGIN { OFS="|" } NR==1 {print $1, $2, $3, $4, $5, $6; next} $7=="N" {
        print $1, $2, $3, $4, $5, $6; next} $0 ~ /File Creation Time/ {print; next} ' other_listed_withTests.txt >> other_listed.txt

        printf "Done with other_listed\n\n"

else
    printf "Downloading of \"other_listed\" list failed. Check address or source.\n"
fi

printf "Converting to list of JSON object and creating new files..\n"

awk -F'|' 'NR>1 && $1 !~ /File Creation Time/ {
printf("{\"Symbol\":\"%s\", \"Security\":\"%s\", \"Market\":\"%s\", \"Financial\":\"%s\", \"LotSize\":\"%s\", \"ETF\":\"%s\"}\n", $1, $2, $3, $4, $5, $6)
}' Nasdaq.txt | jq -s '.' > Nasdaq.json

awk -F'|' 'NR>1 && $1 !~ /File Creation Time/ {
printf("{\"ACT Symbol\":\"%s\", \"Security Name\":\"%s\", \"Exchange\":\"%s\", \"CQS Symbol\":\"%s\", \"ETF\":\"%s\", \"Round Lot Size\":\"%s\"}\n", $1, $2, $3, $4, $5, $6)
}' other_listed.txt | jq -s '.' > other_listed.json


printf "Done.\n\n"

