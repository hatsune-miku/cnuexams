<script>
    import axios from 'axios';

    export default {
        getReusedSession: function(that) {
            if (!that.$cookies.isKey('session'))
                return '';
            return that.$cookies.get('session');
        },

        removeReusedSession: function(that) {
            that.$cookies.remove('session');
        },

        mikutart: function (path, intent, params) {
            return axios.post(path, {
                intent: intent,
                params
            });
        }
    }
</script>
