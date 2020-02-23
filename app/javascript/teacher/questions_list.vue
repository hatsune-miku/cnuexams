<template>
    <div>
        <genreal-table-viewer table-name="题目" controller-name="questions" :data="data" :search-filter="filter"/>
    </div>
</template>


<script>
    import GenrealTableViewer from './GenrealTableViewer';
    export default {
        components: { GenrealTableViewer },
        data: function() {
            return {
                data: [
                    { key: 'id', label: '题号' },
                    { key: 'summary', label: '题干', width: '300px' },
                    { key: 'options', label: '选项', width: '220px' },
                    { key: 'answer', label: '答案', width: '140px' },
                    { key: 'score', label: '分值' },
                    { key: 'essential', label: '固定题？', type: 'single-select', params:[
                            { name: '是', value: 1 },
                            { name: '否', value: 0 }
                        ]
                    },
                    { key: 'kind', label: '选项类型', type: 'single-select', params: [
                            { name: '单选', value: 0 },
                            { name: '多选', value: 1 },
                            { name: '判断', value: 2 }
                        ]
                    },
                    { key: 'cate', label: '题目类型', type: 'single-select', params: [
                            { name: '理科', value: 0 },
                            { name: '文科', value: 1 },
                            { name: '通用-文件', value: 2 },
                            { name: '通用-视频', value: 3 }
                        ]
                    },
                    { key: 'exam', label: '所属考试 ID', width: '120px' },
                    { key: 'label', label: '标签' }
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
