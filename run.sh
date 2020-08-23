#!/bin/bash
# Setup Main Container for Project
MAIN_CONTAINER=backend

function compose() {
  CI_REGISTRY=localhost RELEASE_VERSION=local docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.local.yml -p django-tutorial $@
}

case $1 in
  help|-h|--help)
  echo "Usage:"
  echo "./run.sh                                      -> UP containers in detach mode"
  echo "./run.sh bash|-sh                             -> Open bash in main container"
  echo "./run.sh build|-b <optional params>           -> BUILD containers"
  echo "./run.sh build-force|-bf <optional params>    -> Force build containers (with params no-cache, pull)"
  echo "./run.sh custom_command|-cc                   -> Custom docker-compose command"
  echo "./run.sh create_django_secret|-crs            -> Create Django Secret Key"
  echo "./run.sh create_superuser|-csu <password>     -> Create default super user"
  echo "./run.sh down|-dn                             -> DOWN (stop and remove) containers"
  echo "./run.sh downv|-dnv                           -> DOWN (stop and remove with volumes) containers"
  echo "./run.sh help|-h                              -> Show this help message"
  echo "./run.sh install|-i                           -> Install local development setup"
  echo "./run.sh logs|-l <optional params>            -> LOGS from ALL containers"
  echo "./run.sh logsf|-lf <optional params>          -> LOGS from ALL containers with follow option"
  echo "./run.sh shell|-sl                            -> Open shell in main container"
  echo "./run.sh shell_plus|-sp                       -> Open shell plus (only if django_extensions installed) in main container"
  echo "./run.sh makemigrate|-mm <optional params>    -> Make migrations and migrate inside main container"
  echo "./run.sh notebook|-nb                         -> Run notebook (only if django_extensions installed)"
  echo "./run.sh recreate|-rec <optional params>      -> Up and recreate containers"
  echo "./run.sh recreated|-recd <optional params>    -> Up and recreate containers in detach mode"
  echo "./run.sh restart|-r <optional params>         -> Restart containers"
  echo "./run.sh rm|-rm <optional params>             -> Remove force container"
  echo "./run.sh stop|-s <optional params>            -> Stop containers"
  echo "./run.sh test|-t <optional params>            -> Run tests"
  echo "./run.sh up|-u <optional params>              -> UP containers with output"
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
  create_django_secret|-crs)
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
  install|-i)
  LOCAL_FILES="
  ./app/django_tutorial/local_settings.py.example
  ./envs/.env.local.example
  ./docker/docker-compose.local.yml.example
  ./docker/entrypoint.local.sh.example
  ./configs/requirements.local.txt.example"
  for f in $LOCAL_FILES
  do
    cp "$f" "${f::-8}"
  done
  compose build
  DJANGO_SECRET_KEY=$(echo "from django.core.management.utils import get_random_secret_key;print(get_random_secret_key())" | ./run.sh -cc run --no-deps --rm backend django-admin shell)
  sed -i 's|DJANGO_SECRET_KEY=""|DJANGO_SECRET_KEY="'"$DJANGO_SECRET_KEY"'"|' ./envs/.env.local
  exit
  ;;
  create_superuser|-csu)
  if [[ -z "$2" ]]; then
    echo -e "You must provide an admin password as param f.g. \n$ ./run.sh -csu admin"
    exit
  fi
  echo "import os; from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@email.com', '$2') if not User.objects.filter(username='admin').exists() else print('Admin account exist.')" | compose exec -T $MAIN_CONTAINER "python manage.py shell"
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
  compose exec $MAIN_CONTAINER "python manage.py test ${@:2}"
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
