#library(tidyverse)
`%!in%` = function(x, y) !(x%in%y)
`%>%` = dplyr::`%>%`
# * GLOBAL ----
SEASON = 2019
# * Team Data ----
teams = read.csv(paste0('round_of_16/data/round_of_16_', SEASON, '.csv'),
                 stringsAsFactors = FALSE)
winners = teams %>% dplyr::filter(place_in_group == 1)
runners_up = teams %>% dplyr::filter(place_in_group == 2)

# Create a data frame for each runner up who they could play
create_valid_draws = function(runners_up, winners) {
  runner_up_df = data.frame(n = 1:length(winners$team_name))
  for (team in runners_up$team_name) {
    team_country = runners_up %>% dplyr::filter(team_name == team) %>% dplyr::select(country)
    team_country = team_country[[1]]
    team_group = runners_up %>% dplyr::filter(team_name == team) %>% dplyr::select(group)
    team_group = team_group[[1]]
    
    possible_winners = winners %>% dplyr::filter(country != team_country,
                                                 group != team_group) %>%
                          dplyr::select(team_name)
    
    runner_up_df[,team] = c(possible_winners$team_name, rep(NA, nrow(runner_up_df) - nrow(possible_winners)))
  }
  return(runner_up_df)
}

# Draw functions ----

# Draw a winner for a given runner up team
draw_one = function(valid_draws, runner_up) {
  possible_teams = valid_draws[,runner_up]
  possible_teams = possible_teams[!is.na(possible_teams)]
  if (length(possible_teams) == 0) {
    winner = NA
  }
  # If there is only one possible option, just pick that option
  else if (length(possible_teams) == 1) {
    winner = possible_teams[1]
  }
  # If not, just pick a random one
  else {
    winner = sample(possible_teams, 1)
  }
  # Remove winner from all possible lists
  if (!is.na(winner)) {
    valid_draws[valid_draws == winner] = NA  
  }
  # Return the winner and the updated data frame of possible teams
  return(list(winner = winner, valid_draws = valid_draws))
}

# Draw one round
draw_one_round = function(valid_draws) {
  # Createa matrix of 0's to update.
  mat = matrix(rep(0, 64), nrow = 8)
  rownames(mat) = runners_up$team_name
  colnames(mat) = winners$team_name
  # Sample order of runner up teams
  draw_seq = sample(1:8, 8)
  #winner_list = c()
  for (team_idx in draw_seq) {
    runner_up = runners_up[team_idx, "team_name"]
    # Draw for that team
    winner_result = draw_one(valid_draws, runner_up)
    # Get winner
    winner = winner_result$winner
    # Update possible winners
    valid_draws = winner_result$valid_draws

#     k = 0
#     repeat {
#       if (k >= 100) {
# #        print(paste0("Infinite Loop with team ", runner_up))
#         winner = NA
#         break
#       }
#       winner_result = draw_one(runner_up_df, runner_up)
#       winner = winner_result$winner
#       runner_up_df = winner_result$runner_up_df
#       # No possible winners available, abort
#       if (winner == -1) {
#         winner = NA
#         break
#       }
#       # A new winner was picked
#       else if (winner %!in% winner_list) {
#         winner_list = c(winner, winner_list)
#         break
#       }
#       else {
#         winner_list = c(winner, winner_list)
#       }
#       k = k + 1
#     } # repeat
    # No winner was found so put -1 in to show it was a failed attempt
    if (is.na(winner)) {
      return(-1)
    }
    else {
      mat[rownames(mat) == runner_up ,colnames(mat) == winner] = 1
    }
  } # for
  return(mat)
}

# Run n simulations
draw_n_simulations = function(n) {
  # Createa matrix of 0's to update.
  mat = matrix(rep(0, 64), nrow = 8)
  rownames(mat) = runners_up$team_name
  colnames(mat) = winners$team_name
  valid_draws = create_valid_draws(runners_up, winners)
  `%dopar%` = foreach::`%dopar%`
  # Set up parallel running
  cores = parallel::detectCores()
  cl = parallel::makeCluster(cores[1] - 1)
  doParallel::registerDoParallel(cl)
  # Run over each season
  # This runs stuff in parallel.
  final_mat = foreach::foreach(draw = 1:n, .combine='+', .export = c('draw_one_round', 'draw_one',
                                                                     'winners', 'runners_up')) %dopar% {
    `%>%` = dplyr::`%>%`
    `%!in%` = function(x, y) !(x%in%y)
    success = FALSE
    while (!success) {
      mat_temp = draw_one_round(valid_draws)
      # If we have a draw
      if (sum(mat_temp == -1) == 0) {
        success = TRUE
      }
    }
    return(mat_temp)
  }
  # Stop parralel
  parallel::stopCluster(cl)
  
  return(final_mat)
}

results = draw_n_simulations(100000)
prop_results = apply(results, 2, function(x) round(100*(x/sum(x)),0))
