import Arweave from "arweave";

const arweave = Arweave.init({
  host: "arweave.net",
  port: 443,
  protocol: "https",
});

export const getPosts = new Promise<Array<Object>>((resolve, reject) => {
  async function getTransanctionIds() {
    await fetch('https://arweave.net/graphql', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query: `
                query {
                    transactions(
                      first: 100
                      sort: HEIGHT_DESC
                      tags: [
                        {
                          name: "Contributor"
                          values: ["0x5b796c4B197B6DfD413f177059C27963EB80af0F","0x2b1F13149C7F89622BBfB46Ae1e3ECc573Bb9331","0x381636D0E4eD0fa6aCF07D8fd821909Fb63c0d10"]
                        },
                        {
                          name: "App-Name"
                          values: "MirrorXYZ"
                        }
                      ]
                    ) {
                      edges {
                        node {
                          id
                        }
                      }
                    }
                  }
              `})
    }).then((res) => res.json())
      .then((response) => {
        const transactionCount = response.data.transactions.edges.length;
        console.log("Amount of transactions: " + transactionCount);


        getPosts(response, transactionCount)
      })
      .catch((error) => {
        console.log("An error occurred: ", error);
      });
  }

  async function getPosts(response, transactionCount) {
    var posts = []
    for (let i = 0; i < transactionCount; i++) {
      var transactionId = response.data.transactions.edges[i].node.id;
      await arweave.transactions
        .getData(`${transactionId}`, { decode: true, string: true })
        .then((data: string) => {
          posts.push(JSON.parse(data))
        }).catch((error) => {
          console.log("An error occurred: ", error);
        });

    }
    resolve(posts)
  }
  getTransanctionIds()
})