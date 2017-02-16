tesla.com
model3.tesla.com
teslamotors.com

workspaces add tesla.com
add domains tesla.com
add domains teslamotors.com
use recon/domains-hosts/shodan_hostname
run
use reporting/csv
run
# spool here for filename?
# [*] 8 records added to '/root/.recon-ng/workspaces/tesla.com/results.csv'.
exit
cp /root/.recon-ng/workspaces/tesla.com/results.csv recon-ng.$domain.csv
cut -d',' -f2 recon-ng.$domain.csv | tee recon-ng.$domain.hosts
