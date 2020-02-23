lsof -i:3000 | grep ruby | awk '{print $2}' | xargs kill -9
