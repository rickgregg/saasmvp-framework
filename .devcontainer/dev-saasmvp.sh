#!/bin/bash
# executes script from root path
dbinit(){
  echo ""
  # create prisma client
  npx prisma generate --schema=./database/schema.prisma
  # migrate and seed the saasmvp database
  ./database/dbconfig.sh dev
  echo $(date) > ./.devcontainer/install.log
  echo "saasmvp database configured"
}

if test -f ./.devcontainer/install.log
then
  while
    true
  do
    echo ""
    read -n1 -p "The database has already been initialized. Migrate and reseed? (y/N):" answer 
    if [[ $answer == "" ]] || [[ $answer == "y" ]] || [[ $answer == "N" ]]
    then
      if [[ $answer != "" ]]
      then
        echo ""
      fi
      break
    fi
  done

  while
    true
  do
    if [[ $answer == "y" ]]
    then
      read -n1 -p "Are you sure? (y/N):" answer
      if [[ $answer == "" ]] || [[ $answer == "y" ]] || [[ $answer == "N" ]]
      then
        if [[ $answer == "y" ]]
        then
          dbinit
          break
        else
          break
        fi
      fi
    else
      break
    fi 
  done
else
  dbinit
fi

# install debian v11 (bullseye) packages
# goes here if needed

# run nuxt app
echo "start nuxt app"
npm run dev 
# done with script
exit