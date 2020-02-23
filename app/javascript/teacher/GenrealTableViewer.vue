<template>
    <div style="width: 100%; height: 100%;">
        <el-container aria-orientation="horizontal" style="margin: 10px;">

            <table style="width: 100%;">
                <tr>
                    <td align="left">
                        <el-dropdown class="horiz-cell" trigger="click" @command="actionAddCorp" v-if="!viewOnly">
                            <el-button size="small" icon="el-icon-plus">
                                新增{{tableName}}<i class="el-icon-arrow-down el-icon--right"></i>
                            </el-button>
                            <el-dropdown-menu slot="dropdown">
                                <el-dropdown-item command="one">新增一位</el-dropdown-item>
                                <el-dropdown-item command="more">批量导入</el-dropdown-item>
                            </el-dropdown-menu>
                        </el-dropdown>

                        <el-button type="danger" size="small" class="horiz-cell" icon="el-icon-error" @click="actionDeleteCorps">
                            删除所选{{tableName}}
                        </el-button>
                    </td>

                    <td align="right">
                        <el-input v-model="search" @keydown.native.enter="actionSearch" class="horiz-cell" style="width: 220px;" size="small" placeholder="模糊搜索..."/>
                        <el-button @click="actionSearch" size="small" icon="el-icon-search"/>
                    </td>
                </tr>
            </table>


        </el-container>

        <el-pagination :hide-on-single-page="true"
                       @current-change="switchToPage"
                       layout="total, prev, pager, next, jumper"
                       :disabled="loading"
                       :page-size="48" :total="itemCount"/>

        <el-table :data="items"
                  :row-style="tableTransparentApplier"
                  :header-cell-style="tableTransparentApplier"
                  @selection-change="onSelectionChanged"
                  @row-click="onRowClicked"
                  class="clickable-table"
                  v-loading="loading"
                  element-loading-text="Now Loading..."
                  element-loading-spinner="el-icon-loading"
                  element-loading-background="rgba(0, 0, 0, 0.8)">

            <el-table-column type="selection"/>
            <el-table-column v-for="dat in data" :key="dat.key" v-if="!dat.invisible"
                             :label="dat.label" :prop="dat.key" :width="dat.width">
                <span slot-scope="scope">
                    {{(dat.postProcessor || (d => d))(friendlyData(dat, scope.$index))}}
                </span>
            </el-table-column>
            <el-table-column v-if="showTooltips" fixed="right" label="状态" :width="120">
                <template slot-scope="scope">
                    <slot :item="items[scope.$index]"/>
                </template>
            </el-table-column>

        </el-table>

        <property-editor :properties="data"
                         :visibility="shouldShowPropertyEditor"
                         :title="(editing ? '修改' : '添加') + tableName"
                         :initValue="initValue"
                         :on-confirmed="actionConfirmedAddingItem"
                         :on-cancelled="actionCancel"/>

        <alert-box :visibility="shouldShowAlertBox" :message="'确认要删除所选' + tableName + '吗？'" :on-yes="performDeleteCorps" :on-no="actionCancel"/>
        <upload-box v-if="shouldShowUploadBox" title="批量导入" :db-name="controllerName" :on-cancelled="actionCancelUpload" :on-success="onUploadSuccess"/>
    </div>
</template>

<style scoped>
    .horiz-cell {
        margin-left: 20px;
    }
    /deep/ .clickable-table .el-table__row:hover {
        cursor: pointer;
    }
</style>

<script>

    import axios from 'axios';
    import PropertyEditor from "../PropertyEditor";
    import AlertBox from "../AlertBox";
    import UploadBox from "./UploadBox";
    export default {
        components: { UploadBox, AlertBox, PropertyEditor },
        props: {
            tableName: {
                type: String
            },
            controllerName: {
                type: String
            },
            data: {
                type: Array
            },
            searchFilter: {
                type: Function
            },
            viewOnly: Boolean,
            showTooltips: Boolean,
            aliasor: Function
        },
        data: function() {
            return {
                items: [],
                itemCount: 0,
                currentPageIndex: 1,
                whereCondition: '1 = 1',
                search: '',
                loading: true,
                shouldShowPropertyEditor: false,
                shouldShowAlertBox: false,
                shouldShowUploadBox: false,
                stupid: false,
                editing: false,
                initValue: {},
                selections: []
            };
        },

        created() {
            this.performRefresh();
        },

        mounted() {

        },
        methods: {
            friendlyData(dat, index) {
                let originValue = this.items[index][dat.key];

                if (this.aliasor)
                    originValue = this.aliasor(originValue);

                if (!dat.params)
                    return originValue;
                for (let param of dat.params)
                    if (param.value === originValue)
                        return param.name;
                return originValue;
            },
            performRefresh() {
                axios.post('/' + this.controllerName + '/', {
                    intent: 'count',
                    where: this.whereCondition
                })
                .then(res => {
                    this.itemCount = res.data.response.count;
                    this.switchToPage(this.currentPageIndex);
                });
            },
            switchToPage(pageIndex) {
              this.currentPageIndex = pageIndex;
              this.loading = true;
              axios.post('/' + this.controllerName + '/', {
                  intent: 'list',
                  where: this.whereCondition,
                  limit: 48,
                  offset: (this.currentPageIndex - 1) * 48
              }).then(res => {
                  this.items = res.data.response;
              }).finally(() => {
                  this.loading = false;
              });
            },
            tableTransparentApplier() {
                return 'background-color: #FCFAF2;';
            },
            actionAddCorp(command) {
                if (command === 'one') {
                    this.editing = false;
                    this.initValue = {};
                    this.shouldShowPropertyEditor = true;
                }
                else if (command === 'more') {
                    this.shouldShowUploadBox = true;
                }
            },
            actionDeleteCorps() {
                if (this.selections.length === 0)
                    return;
                this.stupid = true;
                this.shouldShowAlertBox = true;
            },
            performDeleteCorps() {
                this.shouldShowAlertBox = false;
                console.log(this.selections);
                axios.post('/' + this.controllerName + '/', {
                    intent: 'destroy',
                    data: this.selections
                }).then(res => {
                    this.$notify({type: 'success', message: res.data.message});
                    this.performRefresh();
                });
                this.stupid = false;
            },
            actionCancel() {
                this.stupid = false;

                this.shouldShowPropertyEditor = false;
                this.shouldShowAlertBox = false;
            },
            onRowClicked(row) {
                if (this.viewOnly)
                    return;

                for (let dat of this.data) {
                    if (dat.type === 'multi-select')
                        this.initValue[dat.key] = JSON.parse(row[dat.key] || '[]');
                    else
                        this.initValue[dat.key] = row[dat.key];
                }

                this.editing = true;
                this.shouldShowPropertyEditor = true;
            },
            onSelectionChanged(selection) {
                if (this.stupid)
                    return;
                this.selections = selection;
            },
            actionConfirmedAddingItem(corp) {
                this.shouldShowPropertyEditor = false;

                // make data.
                let data = {};
                for (let dat of this.data) {
                    if (dat.givenValue !== undefined)
                        data[dat.key] = dat.givenValue;
                    else if (!dat.uninputable || this.editing)
                        data[dat.key] = corp[dat.key];
                }

                axios.post('/' + this.controllerName + '/', {
                    intent: this.editing ? 'update' : 'create',
                    data: data
                }).then(res => {
                    if (res.data.errorcode !== 0) {
                        this.$notify({type: 'error', message: res.data.message});
                        return;
                    }
                    this.$notify({type: 'success', message: res.data.message});
                    this.performRefresh();
                });
            },
            actionSearch() {
                let groupedConditions = [];
                this.search.replace(',', ' ').split(' ').forEach(keyword => {
                    if (keyword === '')
                        return;
                    let conditions = [];
                    for (let dat of this.data)
                        conditions.push(`(${dat.key} like '%${keyword}%')`);
                    groupedConditions.push(conditions.join(' or '));
                });
                this.whereCondition = groupedConditions.join(' or ');
                this.currentPageIndex = 1;
                this.performRefresh();
            },
            actionCancelUpload() {
                this.shouldShowUploadBox = false;
            },
            onUploadSuccess() {
                this.performRefresh();
            }
        }
    };
</script>
