<template>
  <div>
    <div class="top-right wrap-content eggtart-div" style="color: black; height: calc(30px + fit-content); width: 300px; background: #FEFEFE;">
      <div style="margin-left: 20px;">
        <p style="size: 12px">CNU Exams<br/>首都师范大学 信息工程学院<br/></p>
        <p>欢迎问题反馈和建议<br/>email: eggtart@mikutart.com<br/>wechat: a1knla</p>
        <el-button type="danger" plain>Source Code</el-button>
      </div>
    </div>
    <div class="top-left">
      CNU Exams
    </div>
    <div class="right-bottom">
      <el-row>
        <div class="eggtart-div wrap-content" style="width: 300px; background: #FEFEFE;">
          <!-- 8E354A -->
          <div style="margin-left: 60px; margin-right: 60px; text-align: center;">
            <p class="bold">CNU Exams</p>
            <el-row>
              <el-col>
                <el-input placeholder="学号"
                          size="medium"
                          v-model="username"
                          clearable
                          @keyup.native.enter="actionLogin"/>
              </el-col>
            </el-row>
            <el-row style="margin-top: 5px;">
              <el-col>
                <el-input placeholder="密码"
                          size="medium"
                          v-model="password"
                          clearable
                          show-password
                          @keyup.native.enter="actionLogin"/>
              </el-col>
            </el-row>
          </div>
        </div>
      </el-row>

      <el-row style="margin-top: 15px;">
        <el-col :span=12 align="center">
          <el-button circle
                     type="warning"
                     icon="el-icon-edit"
                     @click="actionRegister"/>
        </el-col>
        <el-col :span=12 align="center">
          <el-button circle
                     :loading="loading"
                     :type="type"
                     icon="el-icon-check"
                     @click="actionLogin"/>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
  import axios from 'axios';
  import utils from 'utils';

  export default {
    data: function () {
      return {
        username: '',
        password: '',
        type: 'danger',
        loading: false
      };
    },

    mounted() {
      let sessionId = utils.getReusedSession(this);
      console.log('saved session: ' + sessionId);

      axios.post('/users/', {
        intent: 'reuse',
        sessionId: sessionId
      })
      .then(res => {
        if (res.data.errorcode !== 0)
          return;

        this.$router.push('/overview');
      });
    },

    methods: {
      actionRegister() {
        window.location.href = '/user/sign_up';
      },

      actionLogin() {
        this.loading = true;

        axios.post('/users/', {
          intent: 'login',
          username: this.username,
          password: this.password
        }).then(res => {

          if (res.data.errorcode === 0) {
            this.$cookies.set('session', res.data.response.session_id);
            this.$cookies.set('username', this.username);
            this.$cookies.set('name', res.data.response.name);
          }

          window.location.href = '/';

        }).finally(() => {
          this.loading = false;
        });
      }
    }
  }
</script>
