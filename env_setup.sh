# ENV variables
APP_FILE=Example/Example/Env.swift
TEST_FILE=Tests/CourierTests/Env.swift

# Create the app file env
if [[ ! -e $APP_FILE ]]
then
  cp EnvSample.swift $APP_FILE
fi

# Create the androidTest env
if [[ ! -e $TEST_FILE ]]
then
  cp EnvSample.swift $TEST_FILE
fi

echo "🙌 Env files created"
