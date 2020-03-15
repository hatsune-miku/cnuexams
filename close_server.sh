lsof -i:80 | grep ruby | awk '{print $2}' | xargs kill -9
