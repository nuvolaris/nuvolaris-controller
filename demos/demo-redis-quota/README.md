First, setup redis: bash setup.sh to install redis in ubuntu for thest

To test, fill a prefix with some random keys (1k each)
bash fill.sh <prefix> <n>

Then you can check providing the prefixes to check (as I assume we know them )""

bash check.sh <prefx> <prefix>...

Example:

```
bash fill.sh mike 100
bash check.sh mike franz
bash fill.sh franz 200
bash check.sh mike franz
```