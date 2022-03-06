class LocalStorage {

    static getString(key) {
        return localStorage.getItem(key);
    }

    static setString(key, value) {
        localStorage.removeItem(key);
        if (value) {
            localStorage.setItem(key, value);
        }
    }

    static getObject(key) {
        const value = this.getString(key);
        return JSON.parse(value);
    }

    static setObject(key, value) {
        this.setString(key, JSON.stringify(value));
    }

    static getNumber(key) {
        const value = this.getString(key);
        return value ? Number(value) : null;
    }

    static setNumber(key, value) {
        this.setString(key, value ? value.toString() : null);
    }
}

window.LocalStorage = LocalStorage;
