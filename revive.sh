#!/bin/bash
# 본 스크립트를 실행할 시 받은 인자의 명령을 실행하고, 아래의 기능을 수행합니다.
#   - 인자의 명령이 0이 아닌 값으로 종료되면, 텔레그램 봇을 통해 알림을 보내고 인자의 명령을 다시 실행합니다.
#   - 인자의 명령이 0으로 종료되면, 텔레그램 봇을 통해 알림을 보내고 스크립트를 종료합니다.
# - PID_FILE_PATH이 주어질 시
#   - 중복 실행을 방지하기 위해, PID_FILE_PATH에 파일이 존재한다면 본 스크립트를 종료합니다.
#   - PID_FILE_PATH에 PID를 저장합니다.
# - ON_STARTUP_EXEC가 주어질 시, 프로세스 시작 전 해당 스크립트를 실행합니다.
# - ON_CLEANUP_EXEC가 주어질 시, 프로세스 종료 후 해당 스크립트를 실행합니다.

# 인자는 1개 이상이어야 합니다.
if [ "$#" -lt 1 ]; then
    echo "ERROR: At least one argument shoud be given."
    exit 1
fi

# 필요한 변수들을 환경변수로부터 가져오고, 만약 없다면 에러를 출력하고 종료합니다.
function get_env_var() {
    local name="$1"
    local value="${!name}"
    if [ -z "$value" ]; then
        echo "ERROR: environment variable $name is not set"
        exit 1
    fi
    echo "$value"
}

TELEGRAM_BOT_TOKEN=$(get_env_var TELEGRAM_BOT_TOKEN)
TELEGRAM_CHAT_ID=$(get_env_var TELEGRAM_CHAT_ID)
SERVICE_NAME=${SERVICE_NAME:-"$1"}
PID_FILE_PATH=${PID_FILE_PATH:-''}
ON_STARTUP_EXEC=${ON_STARTUP_EXEC:-''}
ON_CLEANUP_EXEC=${ON_CLEANUP_EXEC:-''}

# PID_FILE_PATH에 해당하는 파일이 존재한다면 본 스크립트를 종료합니다.
if [ -f "$PID_FILE_PATH" ]; then
    echo "ERROR: $SERVICE_NAME is already running!"
    exit 1
else
    # PID_FILE_PATH가 존재하고 PID 파일을 생성하고자 하는 디렉토리가 없을 경우
    # 해당 파일의 경로를 생성합니다.
    if [ -n "$PID_FILE_PATH" ]; then mkdir -p "$(dirname "$PID_FILE_PATH")"; fi
fi

# 텔레그램 봇을 통해 알림을 보내는 함수
function send() {
    echo "$1"
    curl -s -X POST \
        "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$1" \
        -s > /dev/null
}

trap 'sleep 2 && ps $PID > /dev/null && kill -s TERM $PID' QUIT INT TERM EXIT

# ON_STARTUP_EXEC가 주어졌다면 해당 스크립트를 실행합니다.
# 또한, 만약 주어진 파일이 sh 파일이라면, source 명령을 통해 실행합니다.
if [ -n "$ON_STARTUP_EXEC" ]; then
    if [ "${ON_STARTUP_EXEC##*.}" = "sh" ]; then
        source "$ON_STARTUP_EXEC"
    else
        "$ON_STARTUP_EXEC"
    fi
fi

# 인자의 명령을 실행하고, 종료 상태를 확인하여 알림을 보내고 종료 상태가 0이 아니면 다시 실행합니다.
EXIT_STATUS=-1
while [ $EXIT_STATUS -ne 0 ]; do
    "$@" &
    PID=$!

    # PID_FILE_PATH가 존재한다면 PID 파일을 생성합니다.
    if [ -n "$PID_FILE_PATH" ]; then echo "$PID" > "$PID_FILE_PATH"; fi
    send "[$HOSTNAME] PID: $$ / $SERVICE_NAME PID: $PID"

    # 제대로 된 exit status를 얻기 위해 wait를 두 번 호출합니다.
    # 원인은 모르겠지만, 한번만 호출하면 제대로 된 exit status를 얻을 수 없습니다.
    wait $PID
    wait $PID
    EXIT_STATUS=$?

    # PID_FILE_PATH가 존재한다면 PID 파일을 삭제합니다.
    if [ -n "$PID_FILE_PATH" ]; then rm -f "$PID_FILE_PATH"; fi
    send "[$HOSTNAME] $SERVICE_NAME exited with status $EXIT_STATUS!"
done

# ON_CLEANUP_EXEC가 주어졌다면 해당 스크립트를 실행합니다.
if [ -n "$ON_CLEANUP_EXEC" ]; then "$ON_CLEANUP_EXEC"; fi

exit 0
