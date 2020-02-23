<template>
 <div style="height: 100%;">
  <table style="width: 100%;">
   <tr>
    <td align="left">
     <el-pagination :hide-on-single-page="true"
                    @current-change="currentPageChange"
                    layout="total, prev, pager, next, jumper"
                    :disabled="loading"
                    :page-size="48" :total="count"/>
    </td>

    <td align="right">
     <el-checkbox @change="handleAutoRefreshChange">自动刷新</el-checkbox>
     &nbsp;
     <el-button size="small" style="font-size: 12px;" icon="el-icon-refresh-left" @click="refreshCurrentPage"/>

     <el-divider direction="vertical"/>

     <el-dropdown trigger="click" @command="handleAnalyzeCommand">
      <el-button size="small" :disabled="exams.length === 0">
       试题分析<i class="el-icon-arrow-down el-icon--right"></i>
      </el-button>
      <el-dropdown-menu slot="dropdown">
       <el-dropdown-item v-for="exam in exams" :key="exam.id" :command="exam.id + '1jd59rcnodlghy' + exam.name">{{exam.name}}</el-dropdown-item>
      </el-dropdown-menu>
     </el-dropdown>
     <el-dropdown trigger="click" @command="handleExportCommand">
      <el-button size="small" type="primary">
       导出为 Excel 文档<i class="el-icon-arrow-down el-icon--right"></i>
      </el-button>
      <el-dropdown-menu slot="dropdown">
       <el-dropdown-item command="all">导出所有考生</el-dropdown-item>
       <el-dropdown-item command="passed">导出通过了考试的考生</el-dropdown-item>
       <el-dropdown-item command="non-passed">导出没通过考试的考生</el-dropdown-item>
       <el-dropdown-item command="submitted">导出已交卷的考生</el-dropdown-item>
       <el-dropdown-item command="non-submitted">导出尚未交卷的考生</el-dropdown-item>
      </el-dropdown-menu>
     </el-dropdown>
    </td>
   </tr>
  </table>

  <el-table :data="displayData" style="border-radius: 5px;" height="95%"
            :header-cell-style="tableTransparentApplier" :row-style="tableTransparentApplier"
            :empty-text="emptyText"
            v-loading="loading"
            element-loading-text="Now Loading..."
            element-loading-spinner="el-icon-loading"
            element-loading-background="rgba(0, 0, 0, 0.8)">

   <el-table-column prop="username" label="学号" width="100px"/>
   <el-table-column prop="name" label="姓名" width="100px"/>
   <el-table-column prop="institute" label="院系" width="120px"/>
   <el-table-column prop="major" label="专业" width="90px"/>
   <el-table-column prop="exam_id" label="当前考试 ID" width="100px"/>
   <el-table-column prop="status" label="状态" width="90px"/>
   <el-table-column prop="time_started" label="开考时间">
    <span slot-scope="scope">
     {{timestampToTime(scope.row.time_started)}}
    </span>
   </el-table-column>
   <el-table-column prop="time_submitted" label="交卷时间">
    <span slot-scope="scope">
     {{timestampToTime(scope.row.time_submitted)}}
    </span>
   </el-table-column>
   <el-table-column prop="time_elapsed" label="考试用时">
    <span slot-scope="scope">
     {{secondTranslate(scope.row.time_elapsed)}}
    </span>
   </el-table-column>
   <el-table-column prop="score" label="成绩" width="90px"/>
   <el-table-column prop="passed" label="是否通过？" width="90px"/>
  </el-table>

  <property-editor title="生成试题分析报告" :visibility="shouldShowQuestionAnalysis" :properties="properties" :init-value="initValue"
                   :on-cancelled="actionCancelAnalysis" :on-confirmed="actionConfirmAnalysis"/>
 </div>
</template>

<style scoped>
 /deep/ .clickable-table .el-table__row:hover {
  cursor: pointer;
 }
 /deep/ .btn-prev {
  background: transparent;
 }
 /deep/ .btn-prev:disabled {
  background: transparent;
 }
 /deep/ .btn-next {
  background: transparent;
 }
 /deep/ .btn-next:disabled {
  background: transparent;
 }
 /deep/ .el-pager {
  background: transparent;
 }
 /deep/ .number {
  background: transparent;
 }
 /deep/ .more {
  background: transparent;
 }
</style>

 <script>
  import axios from 'axios'
  import XLSX from '../../assets/javascripts/xlsx.core.min.js'
  import PropertyEditor from "../PropertyEditor";

  export default {
   components: {PropertyEditor},
   data: function() {
    return {
     count: 0,
     emptyText: '没有考生信息',
     loading: false,
     generateProgress: 0,
     displayData: [],
     exportData: [],
     loadingObject: null,
     timerObject: null,
     exams: [],
     currentPageIndex: 1,
     shouldShowQuestionAnalysis: false,
     analysisTargetExamId: 0,
     properties: [
      { key: 'exam_name', readonly: true },
      { key: 'start_time', label: '起始时间', type: 'datetime' },
      { key: 'finish_time', label: '截止时间', type: 'datetime' }
     ],
     initValue: { exam_name: '' }
    };
   },
   created() {
    axios.post('/users/', {
     intent: 'count'
    })
    .then(res => {
     this.count = res.data.response.count;
     this.currentPageChange(1);
    })
    .finally(() => {
     axios.post('/exams/', {
      intent: 'list'
     })
     .then(res => {
      this.exams = res.data.response;
     });
    })
   },
   methods: {
    tableTransparentApplier() {
     return 'background-color: #FCFAF2;';
    },
    handleAutoRefreshChange(autoRefresh) {
     if (autoRefresh)
      this.timerObject = setInterval(this.refreshCurrentPage, 1500);
     else
      clearInterval(this.timerObject);
    },
    fetchForPage(pageIndex) {
     return axios.post('/users/', {
      intent: 'spacelens',
      offset: (pageIndex - 1) * 48,
      limit: 48 });
    },
    currentPageChange(pageIndex) {
     this.currentPage = pageIndex;
     this.loading = true;
     this.fetchForPage(pageIndex)
     .then(res => {
      this.displayData = res.data.response;
     })
     .finally(() => {
      this.loading = false;
     });
    },
    refreshCurrentPage() {
     this.currentPageChange(this.currentPage);
    },
    allJudger(s) {
     return true;
    },
    passedJudger(s) {
     return s.passed === 'Yes';
    },
    nonPassedJudger(s) {
     return !this.passedJudger(s);
    },
    submittedJudger(s) {
     return s.time_submitted > 0;
    },
    nonSubmittedJudger(s) {
     return !this.submittedJudger(s)
    },
    exporter(judger, pageIndex) {
     if (pageIndex === undefined) {
      this.exportData = [['学号', '姓名', '院系', '专业', '当前考试 ID', '答题状态', '开考时间', '交卷时间', '考试用时', '成绩', '是否通过']];
      this.loadingObject = this.$loading({
       lock: true,
       text: `正在生成 Excel 文档 (${this.generateProgress}%)`,
       spinner: 'el-icon-loading',
       background: 'rgba(0, 0, 0, 0.7)'
      });

      this.exporter(judger, 1);
      return;
     }

     if (pageIndex > Math.ceil(this.count / 48.0)) {
      let sheet = XLSX.utils.aoa_to_sheet(this.exportData);
      this.openDownloadDialog(this.sheet2blob(sheet), 'cnuexams-export.xlsx');
      this.exportData = [];
      this.loadingObject.close();
      return;
     }

     this.generateProgress = Math.ceil(pageIndex / Math.ceil(this.count / 48.0) * 100);

     this.fetchForPage(pageIndex)
             .then(res => {
              res.data.response.forEach(s => {
               if (judger(s)) {
                this.exportData.push([
                 s.username,
                 s.name,
                 s.institute,
                 s.major,
                 s.exam_id,
                 s.status,
                 this.timestampToTime(s.time_started),
                 this.timestampToTime(s.time_submitted),
                 this.secondTranslate(s.time_elapsed),
                 s.score,
                 s.passed
                ]);
               }
              });

              // next circle.
              this.exporter(judger, pageIndex + 1);
             });
    },
    s2ab(s) {
     let buf = new ArrayBuffer(s.length);
     let view = new Uint8Array(buf);
     for (let i = 0; i < s.length; i++)
      view[i] = s.charCodeAt(i) & 0xFF;
     return buf;
    },
    sheet2blob(sheet, sheetName) {
     sheetName = sheetName || 'sheet1';
     let workbook = {
      SheetNames: [sheetName],
      Sheets: {}
     };
     workbook.Sheets[sheetName] = sheet;
     let wopts = {
      bookType: 'xlsx',
      bookSST: false,
      type: 'binary'
     };
     let wbout = XLSX.write(workbook, wopts);
     return new Blob([ this.s2ab(wbout) ], { type: "application/octet-stream" });
    },
    openDownloadDialog(url, saveName) {
     if (typeof url == 'object' && url instanceof Blob) {
      url = URL.createObjectURL(url);
     }
     let aLink = document.createElement('a');
     aLink.href = url;
     aLink.download = saveName || '';
     var event;
     if (window.MouseEvent) {
      event = new MouseEvent('click');
     }
     else {
      event = document.createEvent('MouseEvents');
      event.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
     }
     aLink.dispatchEvent(event);
    },
    handleExportCommand(command) {
     this.exporter({
      'all': this.allJudger,
      'passed': this.passedJudger,
      'non-passed': this.nonPassedJudger,
      'submitted': this.submittedJudger,
      'non-submitted': this.nonSubmittedJudger
     }[command]);
    },
    handleAnalyzeCommand(command) {
     let examInfo = command.split('1jd59rcnodlghy');
     this.analysisTargetExamId = examInfo[0];
     this.initValue.exam_name = examInfo[1];
     this.shouldShowQuestionAnalysis = true;
    },
    actionConfirmAnalysis(options) {
     if (options.start_time >= options.finish_time) {
      this.$notify({ type: 'error', message: '起始时间不能大于结束时间' });
      return;
     }
     axios.post('/exams/', {
      intent: 'analysis',
      exam_id: this.analysisTargetExamId,
      start_time: options.start_time,
      finish_time: options.finish_time
     })
     .then(res => {
      let questions = res.data.response;
      let ret = [[ '题号', '题干', '出现次数', '正确次数', '错误次数', '正确率', '错误率' ]];

      for (let i in questions) {
       if (!questions.hasOwnProperty(i))
        continue;
       let q = questions[i];
       let total = q.hit + q.miss;
       let hitRate = (100.0 * q.hit / total).toFixed(2) + '%';
       let missRate = (100.0 * q.miss / total).toFixed(2) + '%';

       ret.push([
          q.id, q.summary, total, q.hit, q.miss, hitRate, missRate
       ]);
      }


      let sheet = XLSX.utils.aoa_to_sheet(ret);
      this.openDownloadDialog(this.sheet2blob(sheet), `${this.initValue.exam_name}题目分析.xlsx`);

     });
     this.shouldShowQuestionAnalysis = false;
    },
    actionCancelAnalysis() {
     this.shouldShowQuestionAnalysis = false;
    }

   }
  }
 </script>
