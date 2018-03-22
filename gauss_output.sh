# Level of theory:
grep '#p' *.g09 >> output

echo ' ' | cat >> output

# HOMO/LUMO:
grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha  occ. eigenvalues --' | tail -1 >> output
grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha virt. eigenvalues --' | head -1 >> output

# Energy:
grep 'SCF Done' *.out | tail -1 >> output

