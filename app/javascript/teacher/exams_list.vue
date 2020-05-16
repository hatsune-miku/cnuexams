<template>
    <div>
        <genreal-table-viewer table-name="考试" controller-name="exams" :data="data" :search-filter="filter" show-tooltips>
            <span slot-scope="scope">
                xxx
            </span>
        </genreal-table-viewer>
    </div>
</template>

<script>
    import GenrealTableViewer from './GenrealTableViewer';
    export default {
        components: { GenrealTableViewer },
        data: function() {
            return {
                data: [
                    { key: 'id', label: '考试 ID', width: '70px' },
                    { key: 'name', label: '考试名称' },
                    { key: 'requirement', label: '及格线', width: '140px' },
                    { key: 'retestable', label: '通过后可再考？', width: '150px', type: 'single-select', params: [
                            { name: '是', value: 1 },
                            { name: '否', value: 0 }
                        ]
                    },
                    { key: 'time_limit', label: '考试时间' },
                    { key: 'attend_limit', label: '每日参加次数上限' },
                    { key: 'public', label: '是否公开', type: 'single-select', params: [
                            { name: '公开', value: true },
                            { name: '不公开', value: false }
                        ]
                    },
                    { key: 'policy', label: '分数政策', type: 'single-select', params: [
                            { name: '以最后一次为准', value: 0 },
                            { name: '以最高分为准', value: 1 },
                            { name: '以最低分为准', value: 2 },
                            { name: '取平均', value: 3 }
                        ]
                    }
                ]
            };
        },
        methods: {
            filter(row, keyword) {
                if (!keyword)
                    return true;
                for (let item of this.data)
                    if (row[item.key].toLowerCase().includes(keyword.toLowerCase()))
                        return true;
                return false;
            }
        }
    }
</script>
