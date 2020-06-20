#!/bin/bash
# Setup Main Container for Project
MAIN_CONTAINER=backend

function compose() {
  CI_REGISTRY=localhost RELEASE_VERSION=local docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose-local.yml -p pylog $@
}

case $1 in
  help|-h|--help)
  echo "Usage:"
  echo "./run.sh                                       -> UP containers in detach mode"
  echo "./run.sh bash|-sh                              -> Open bash in main container"
  echo "./run.sh build|-b <optional params>            -> BUILD containers"
  echo "./run.sh build-force|-bf <optional params>     -> Force build containers (no-cache, pull)"
  echo "./run.sh custom_command|-cc                    -> Custom docker-compose command"
  echo "./run.sh down|-dn                              -> DOWN (stop and remove) containers"
  echo "./run.sh downv|-dnv                            -> DOWN (stop and remove with volumes) containers"
  echo "./run.sh logs|-l <optional params>             -> LOGS from ALL containers"
  echo "./run.sh logsf|-lf <optional params>           -> LOGS from ALL containers with follow"
  echo "./run.sh shell|-sl                             -> Open shell in main container"
  echo "./run.sh shell_plus|-sp                        -> Open shell plus (from django_extensions) in main container"
  echo "./run.sh makemigrate|-mm <optional params>     -> make migrations and migrate inside containers"
  echo "./run.sh notebook|-nb                          -> Run notebook"
  echo "./run.sh recreate|-rec <optional params>       -> Up and recreate containers"
  echo "./run.sh recreated|-recd <optional params>     -> Up and recreate containers in detach mode"
  echo "./run.sh restart|-r <optional params>          -> RESTART containers"
  echo "./run.sh rm|-rm <optional params>              -> Remove force container"
  echo "./run.sh stop|-s <optional params>             -> STOP containers"
  echo "./run.sh test|-t <optional params>             -> Run tests from run_pytests.sh"
  echo "./run.sh up|-u <optional params>               -> UP containers with output"
    ;;
  bash|-sh)
  compose exec $MAIN_CONTAINER bash
  exit
  ;;
  build|-b)
  compose build ${@:2}
  exit
  ;;
  build-force|-bf)
  compose build --no-cache --pull ${@:2}
  exit
  ;;
  custom_command|-cc)
  compose ${@:2}
  exit
  ;;
  down|-dn)
  compose down
  exit
  ;;
  downv|-dnv)
  compose down -v
  exit
  ;;
  logs|-l)
  compose logs ${@:2}
  exit
  ;;
  logsf|-lf)
  compose logs -f ${@:2}
  exit
  ;;
  shell|-sl)
  compose exec $MAIN_CONTAINER "python manage.py shell"
  exit
  ;;
  shell_plus|-sp)
  compose exec $MAIN_CONTAINER "python manage.py shell_plus"
  exit
  ;;
  makemigrate|-mm)
  compose exec $MAIN_CONTAINER django-admin makemigrations
  compose exec $MAIN_CONTAINER django-admin migrate
  exit
  ;;
  notebook|-nb)
  compose exec $MAIN_CONTAINER django-admin shell_plus --notebook
  exit
  ;;
  recreate|-rec)
  compose up --force-recreate ${@:2}
  exit
  ;;
  recreated|-recd)
  compose up --force-recreate -d ${@:2}
  exit
  ;;
  restart|-r)
  compose restart ${@:2}
  exit
  ;;
  rm|-rm)
  compose rm -fv ${@:2}
  exit
  ;;
  stop|-s)
  compose stop ${@:2}
  exit
  ;;
  test|-t)
  compose exec $MAIN_CONTAINER "pytest ${@:2}"
  exit
  ;;
  up|-u)
  compose up ${@:2}
  exit
  ;;
  *)
  compose up -d ${@:2}
  exit
  ;;
esac
