const APPWRITE_ENDPOINT = 'https://fra.cloud.appwrite.io/v1';
const APPWRITE_PROJECT_ID = '6a0f8c75000c4e4ac458';
const DATABASE_ID = '6a1f56830019fd131cd8';
const COLLECTIONS = {
    songs: 'songs',
    artists: 'artists',
    subscriptions: 'subscriptions',
    payments: 'payments',
};

let currentUser = null;
let authToken = localStorage.getItem('authToken');

async function login(email, password) {
    const res = await fetch(`${APPWRITE_ENDPOINT}/account/sessions/email`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Appwrite-Project': APPWRITE_PROJECT_ID,
        },
        body: JSON.stringify({ email, password }),
    });

    if (!res.ok) throw new Error('فشل تسجيل الدخول');
    const session = await res.json();
    authToken = session.jwt;
    currentUser = session;
    localStorage.setItem('authToken', session.jwt);
    return session;
}

async function logout() {
    try {
        await apiCall('DELETE', '/account/sessions/current');
    } catch (_) {}
    authToken = null;
    currentUser = null;
    localStorage.removeItem('authToken');
    location.reload();
}

async function apiCall(method, path, body = null) {
    const headers = {
        'Content-Type': 'application/json',
        'X-Appwrite-Project': APPWRITE_PROJECT_ID,
    };
    if (authToken) headers['X-Appwrite-JWT'] = authToken;

    const res = await fetch(`${APPWRITE_ENDPOINT}${path}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : null,
    });

    if (!res.ok) {
        const err = await res.json();
        throw new Error(err.message || 'API Error');
    }
    return res.json();
}

async function listDocuments(collectionId, queries = []) {
    const queryStr = queries.length > 0 ? `?queries=${queries.map(q => encodeURIComponent(q)).join('&')}` : '';
    return apiCall('GET', `/databases/${DATABASE_ID}/collections/${collectionId}/documents${queryStr}`);
}

async function createDocument(collectionId, data) {
    return apiCall('POST', `/databases/${DATABASE_ID}/collections/${collectionId}/documents`, {
        documentId: 'unique()',
        data,
    });
}

async function updateDocument(collectionId, docId, data) {
    return apiCall('PATCH', `/databases/${DATABASE_ID}/collections/${collectionId}/documents/${docId}`, { data });
}

async function deleteDocument(collectionId, docId) {
    return apiCall('DELETE', `/databases/${DATABASE_ID}/collections/${collectionId}/documents/${docId}`);
}

async function createFile(bucketId, file) {
    const formData = new FormData();
    formData.append('fileId', 'unique()');
    formData.append('file', file);

    const headers = {
        'X-Appwrite-Project': APPWRITE_PROJECT_ID,
    };
    if (authToken) headers['X-Appwrite-JWT'] = authToken;

    const res = await fetch(`${APPWRITE_ENDPOINT}/storage/buckets/${bucketId}/files`, {
        method: 'POST',
        headers,
        body: formData,
    });

    if (!res.ok) throw new Error('فشل رفع الملف');
    return res.json();
}

function getFileView(bucketId, fileId) {
    return `${APPWRITE_ENDPOINT}/storage/buckets/${bucketId}/files/${fileId}/view?project=${APPWRITE_PROJECT_ID}`;
}

function getFilePreview(bucketId, fileId) {
    return `${APPWRITE_ENDPOINT}/storage/buckets/${bucketId}/files/${fileId}/preview?project=${APPWRITE_PROJECT_ID}&width=200&height=200`;
}

document.addEventListener('DOMContentLoaded', async () => {
    setupNavigation();
    setupSongForm();
    setupArtistForm();
    await setupLogin();
});

function setupNavigation() {
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
            document.getElementById(`section-${btn.dataset.section}`).classList.add('active');
            document.getElementById('page-title').textContent = btn.textContent.trim();
            if (btn.dataset.section === 'songs') loadSongs();
            if (btn.dataset.section === 'artists') loadArtists();
        });
    });
}

async function setupLogin() {
    document.getElementById('logout-btn').addEventListener('click', logout);

    if (authToken) {
        try {
            await apiCall('GET', '/account');
            document.getElementById('connection-status').textContent = '🟢 متصل';
            await _loadAllData();
            return;
        } catch (_) {
            authToken = null;
            localStorage.removeItem('authToken');
        }
    }
    await _promptLogin();
}

async function _promptLogin() {
    const email = prompt('البريد الإلكتروني للمشرف:');
    const password = prompt('كلمة المرور:');
    if (email && password) {
        try {
            await login(email, password);
            document.getElementById('connection-status').textContent = '🟢 متصل';
            await _loadAllData();
        } catch (_) {
            alert('فشل تسجيل الدخول');
        }
    }
}

async function _loadAllData() {
    loadDashboard();
    loadSongs();
    loadArtists();
    loadSubscriptions();
    loadPayments();
}

function setupSongForm() {
    document.getElementById('add-song-btn').addEventListener('click', () => {
        document.getElementById('song-form').style.display = 'block';
    });

    document.getElementById('cancel-song-btn').addEventListener('click', () => {
        document.getElementById('song-form').style.display = 'none';
        document.getElementById('songForm').reset();
    });

    document.getElementById('songForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const title = document.getElementById('song-title').value;
        const artistId = document.getElementById('song-artist').value;
        const genre = document.getElementById('song-genre').value;
        const isPremium = document.getElementById('song-premium').checked;
        const audioFile = document.getElementById('song-audio').files[0];

        try {
            let audioUrl = '';
            if (audioFile) {
                const uploaded = await createFile('media', audioFile);
                audioUrl = getFileView('media', uploaded.$id);
            }

            await createDocument(COLLECTIONS.songs, {
                title,
                artistId,
                artistName: document.getElementById('song-artist').selectedOptions[0].text,
                genre,
                audioUrl,
                isPremium,
                isVideo: false,
                durationSeconds: 0,
                playCount: 0,
            });

            document.getElementById('song-form').style.display = 'none';
            document.getElementById('songForm').reset();
            loadSongs();
            alert('تم إضافة الأغنية بنجاح');
        } catch (err) {
            alert('خطأ: ' + err.message);
        }
    });
}

function setupArtistForm() {
    document.getElementById('add-artist-btn').addEventListener('click', () => {
        document.getElementById('artist-form').style.display = 'block';
    });

    document.getElementById('cancel-artist-btn').addEventListener('click', () => {
        document.getElementById('artist-form').style.display = 'none';
        document.getElementById('artistForm').reset();
    });

    document.getElementById('artistForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const name = document.getElementById('artist-name').value;
        const bio = document.getElementById('artist-bio').value;

        try {
            await createDocument(COLLECTIONS.artists, { name, bio });
            document.getElementById('artist-form').style.display = 'none';
            document.getElementById('artistForm').reset();
            loadArtists();
            loadSongs();
            alert('تم إضافة الفنان بنجاح');
        } catch (err) {
            alert('خطأ: ' + err.message);
        }
    });
}

async function loadDashboard() {
    try {
        const songs = await listDocuments(COLLECTIONS.songs);
        const artists = await listDocuments(COLLECTIONS.artists);
        const payments = await listDocuments(COLLECTIONS.payments);

        document.getElementById('total-songs').textContent = songs.total || 0;
        document.getElementById('total-artists').textContent = artists.total || 0;

        const revenue = (payments.documents || [])
            .filter(p => (p.data || p).status === 'completed')
            .reduce((sum, p) => sum + ((p.data || p).amount || 0), 0);
        document.getElementById('total-revenue').textContent = `${revenue.toLocaleString()} ريال`;
    } catch (_) {}
}

async function loadSongs() {
    try {
        const result = await listDocuments(COLLECTIONS.songs);
        const tbody = document.getElementById('songs-list');
        tbody.innerHTML = '';

        const artistSelect = document.getElementById('song-artist');
        const artistsResult = await listDocuments(COLLECTIONS.artists);

        artistSelect.innerHTML = '<option value="">اختر الفنان</option>';
        (artistsResult.documents || []).forEach(artist => {
            const opt = document.createElement('option');
            const a = artist.data || artist;
            opt.value = artist.$id;
            opt.textContent = a.name;
            artistSelect.appendChild(opt);
        });

        (result.documents || []).forEach(doc => {
            const d = doc.data || doc;
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${d.title}</td>
                <td>${d.artistName}</td>
                <td>${d.genre}</td>
                <td>${d.durationSeconds ? Math.floor(d.durationSeconds / 60) + ':' + String(d.durationSeconds % 60).padStart(2, '0') : '--:--'}</td>
                <td>${d.isPremium ? '⭐' : '-'}</td>
                <td>
                    <button class="action-btn edit" onclick="alert('تعديل: ${doc.$id}')">✏️</button>
                    <button class="action-btn delete" onclick="deleteSong('${doc.$id}')">🗑️</button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (_) {}
}

async function deleteSong(id) {
    if (!confirm('هل أنت متأكد من حذف هذه الأغنية؟')) return;
    try {
        await deleteDocument(COLLECTIONS.songs, id);
        loadSongs();
    } catch (err) {
        alert('خطأ في الحذف: ' + err.message);
    }
}

async function loadArtists() {
    try {
        const result = await listDocuments(COLLECTIONS.artists);
        const grid = document.getElementById('artists-grid');
        grid.innerHTML = '';

        (result.documents || []).forEach(doc => {
            const d = doc.data || doc;
            const div = document.createElement('div');
            div.className = 'grid-item';
            div.innerHTML = `
                <div style="font-size:40px;">🎤</div>
                <h4>${d.name}</h4>
                <p style="color:#888;font-size:13px;">${d.songCount || 0} أغنية</p>
                <button class="action-btn delete" onclick="deleteArtist('${doc.$id}')">🗑️</button>
            `;
            grid.appendChild(div);
        });
    } catch (_) {}
}

async function deleteArtist(id) {
    if (!confirm('هل أنت متأكد من حذف هذا الفنان؟')) return;
    try {
        await deleteDocument(COLLECTIONS.artists, id);
        loadArtists();
    } catch (err) {
        alert('خطأ في الحذف: ' + err.message);
    }
}

async function loadSubscriptions() {
    try {
        const result = await listDocuments(COLLECTIONS.subscriptions);
        const tbody = document.getElementById('subscriptions-list');
        tbody.innerHTML = '';

        (result.documents || []).forEach(doc => {
            const d = doc.data || doc;
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${d.name}</td>
                <td>${d.price} ريال</td>
                <td>${d.durationDays} يوم</td>
                <td>${d.subscriberCount || 0}</td>
                <td>${d.isActive ? '🟢 نشط' : '🔴 متوقف'}</td>
            `;
            tbody.appendChild(tr);
        });
    } catch (_) {}
}

async function loadPayments() {
    try {
        const result = await listDocuments(COLLECTIONS.payments);
        const tbody = document.getElementById('payments-list');
        tbody.innerHTML = '';

        (result.documents || []).forEach(doc => {
            const d = doc.data || doc;
            const statusMap = {
                completed: '✅ مكتمل',
                pending: '⏳ قيد الانتظار',
                failed: '❌ فشل',
                processing: '🔄 قيد المعالجة',
            };
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${d.userId}</td>
                <td>${d.amount} ريال</td>
                <td>${d.gateway}</td>
                <td>${statusMap[d.status] || d.status}</td>
                <td>${d.paidAt ? new Date(d.paidAt).toLocaleDateString('ar-YE') : '-'}</td>
            `;
            tbody.appendChild(tr);
        });
    } catch (_) {}
}
