# Champions League Knockout Simulation

### Intro
The final whistle in the last group stage games has been blown. The dust has settled and it is time to speculate who your club is going to draw in the round of 16 games. You can easily cross off the teams that play in the same country as your domestic league and that one team that played in the same group as you, but that still leaves around 4-8 teams for you to envision playing two legs against. The cynics promise that their draw will be unfavorable. Us with our conspiracy theory tinfoil hats on will claim that the draw was rigged and certain teams were protected. This leads us to the purpose of simulating the draw beforehand.  

### Input
Currently in this repo there is only the draw simulations for the Round of 16 (A to-do item is to add simulations for forming the groups themselves). The input to the script is a csv file that contains information about the teams that advanced to the knockout round and has columns ```team_name``` | ```country``` | ```group``` | ```place_in_group```. The input file is saved in the `round_of_16/data/` path under the name `round_of_16_XXXX.csv` where the X's represent the season. Then in the `.R` file, there is a global variable `SEASON` that should be changed to fit the corresponding season.

### Output
The output of the script is an 8x8 matrix where the row names are the group runner's up listed in group order and the column names are the group winners. The elements of the matrix is the probability that those two teams draw each other. In the current form the output is not saved anywhere (to-do item to output it in a clean format) so I have been putting the results in an excel file that is saved in the `round_of_16/results` file. The final outputs can also be seen below:

![2019-2020 Results](https://github.com/spoonertaylor/ucl_group_simulation/blob/master/round_of_16/results/round_of_16_results_2020.png)

![2018-2019 Results](https://github.com/spoonertaylor/ucl_group_simulation/blob/master/round_of_16/results/round_of_16_results_2019.png)

### Conclusion
The to-do list for this repo is as follows:
1. Rerun every year at the end of group stage games
2. Output results into cleaner format, get rid of manual excel document
3. Add creation of groups simulations.

And finally:
![Go Blues](https://www.youtube.com/watch?v=lBP7QQYN1IU)
