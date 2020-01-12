<template>
  <div>
    <div class="top-right  eggtart-div" style="color: black; height: 130px; width: 300px; background: #FEFEFE;">
      <div style="margin-left: 20px;">
        <div style="font-size: 15px;">
          <p><b>首都师范大学考试系统</b></p>
          <p style="font-size: 14px;">反馈和建议<br/>wechat: a1knla<br/>️wechat: lxt1025</p>
        </div>
        <el-button v-if="false" type="danger" plain @click="actionGoSourceCode">
          <table>
            <tr>
              <td>
                <svg style="width: 16px; height: 16px;" fill="rgb(218, 123, 120)">
                  <path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path>
                </svg>
              </td>
              <td>
                View Source on Github<br/>(Collaborators Only)
              </td>
            </tr>
          </table>
        </el-button>
      </div>
    </div>
    <div class="top-left">

    </div>
    <div class="right-bottom">
      <el-row>
        <div class="eggtart-div wrap-content" style="width: 300px; background: #FEFEFE;">
          <!-- 8E354A -->
          <form style="margin-left: 60px; margin-right: 60px; text-align: center;">
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
          </form>
        </div>
      </el-row>

      <el-row style="margin-top: 15px;">
        <el-col :span="12" align="center">
          <el-button circle
                     type="warning"
                     icon="el-icon-edit"
                     @click="actionResetPassword"/>
        </el-col>
        <el-col :span="12" align="center">
          <el-button circle
                     :loading="loading"
                     :type="type"
                     icon="el-icon-check"
                     @click="actionLogin"/>
        </el-col>
      </el-row>
    </div>

    <property-editor title="修改密码" :visibility="shouldShowResetPassword" :properties="properties"
                     :on-cancelled="actionCancel" :on-confirmed="actionConfirm"/>
  </div>
</template>

<script>
  import axios from 'axios';
  import utils from 'utils';
  import PropertyEditor from "./PropertyEditor";

  export default {
    components: { PropertyEditor },
    data: function () {
      return {
        username: '',
        password: '',
        type: 'danger',
        loading: false,
        shouldShowResetPassword: false,
        properties: [
          { key: 'id', uninputable: true },
          { key: 'username', label: '学号' },
          { key: 'password', label: '现密码', password: true },
          { key: 'new_password', label: '新密码', password: true },
          { key: 'new_password_verify', label: '确认新密码', password: true }
        ]
      };
    },

    mounted() {
      let sessionId = utils.getReusedSession(this);

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
      actionResetPassword() {
        this.shouldShowResetPassword = true;
      },
      actionConfirm(res) {
        this.shouldShowResetPassword = false;

        if (res.new_password !== res.new_password_verify) {
          this.$notify({ type: 'error', message: '新密码和确认新密码不一致' });
          return;
        }

        axios.post('/users/', {
          intent: 'reset',
          username: res.username,
          password: res.password,
          new_password: res.new_password
        }).then(res => {
          if (res.data.errorcode !== 0) {
            this.$notify({ type: 'error', message: res.data.message });
            return;
          }
          this.$notify({ type: 'success', message: '密码修改成功' });
        });
      },
      actionCancel() {
        this.shouldShowResetPassword = false;
      },
      actionLogin() {
        this.loading = true;


        axios.post('/users/', {
          intent: 'login',
          username: this.username,
          password: this.password
        }).then(res => {

          if (res.data.errorcode !== 0) {
            this.$notify({ type: 'error', message: res.data.message });
            return;
          }
          this.$cookies.set('session', res.data.response.session_id);
          this.$cookies.set('username', this.username);
          this.$cookies.set('name', res.data.response.name);

          window.location.href = '/';

        }).finally(() => {
          this.loading = false;
        });
      },

      actionGoSourceCode() {
        window.open('https://github.com/hatsune-miku/cnuexams');
      }
    }
  }
</script>
